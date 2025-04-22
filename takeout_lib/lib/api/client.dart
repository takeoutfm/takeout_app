// Copyright 2023 defsub
//
// This file is part of TakeoutFM.
//
// TakeoutFM is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// TakeoutFM is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with TakeoutFM.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:takeout_lib/cache/json_repository.dart';
import 'package:takeout_lib/client/provider.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/stats.dart';
import 'package:takeout_lib/tokens/repository.dart';

import 'model.dart';

const defaultPlaylist = '/api/playlist';

class ClientException implements Exception {
  final int statusCode;
  final String? url;

  const ClientException({required this.statusCode, this.url});

  bool get authenticationFailed =>
      statusCode == HttpStatus.networkAuthenticationRequired ||
      statusCode == HttpStatus.unauthorized ||
      statusCode == HttpStatus.forbidden;

  @override
  String toString() => 'ClientException: $statusCode => $url';
}

class _ClientError extends Error {
  final Object? message;

  /// Creates a client error with the provided [message].
  _ClientError([this.message]);

  @override
  String toString() {
    return message != null
        ? 'Client error: ${Error.safeToString(message)}'
        : 'Client error';
  }
}

class CodeError extends Error {}

class InvalidCodeError extends CodeError {}

class _ClientWithUserAgent extends http.BaseClient {
  static final log = Logger();

  final http.Client _client;
  final String _userAgent;

  _ClientWithUserAgent(this._client, this._userAgent);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    log.d('${request.method} ${request.url.toString()}');
    request.headers[HttpHeaders.userAgentHeader] = _userAgent;
    return _client.send(request);
  }
}

typedef FutureGenerator<T> = Future<T> Function();

class TakeoutClient implements ClientProvider {
  static final log = Logger();

  static const fieldAccessToken = 'AccessToken';
  static const fieldRefreshToken = 'RefreshToken';
  static const fieldMediaToken = 'MediaToken';

  static const locationTTL = Duration(hours: 1);
  static const playlistTTL = Duration(minutes: 1);
  static const defaultTTL = Duration(hours: 24);
  static const defaultTimeout = Duration(seconds: 5);
  static const downloadTimeout = Duration(minutes: 5);

  final SettingsRepository settingsRepository;
  final TokenRepository tokenRepository;
  final JsonCacheRepository jsonCacheRepository;
  final String _userAgent;
  late http.Client _client;

  TakeoutClient(
      {required this.settingsRepository,
      required this.tokenRepository,
      required this.jsonCacheRepository,
      String? userAgent})
      : _userAgent = userAgent ?? 'TakeoutFM-App' {
    _client = _ClientWithUserAgent(http.Client(), _userAgent);
  }

  @override
  http.Client get client => _client;

  String get userAgent => _userAgent;

  String get endpoint {
    final settings = settingsRepository.settings;
    if (settings == null) {
      throw StateError('no settings');
    }
    if (settings.endpoint.isEmpty) {
      throw StateError('no endpoint');
    }
    return settings.endpoint;
  }

  Map<String, String> _headersWithAccessToken() {
    return tokenRepository.addAccessToken();
  }

  Map<String, String> _headersWithRefreshToken() {
    return tokenRepository.addRefreshToken();
  }

  Map<String, String> _headersWithMediaToken() {
    return tokenRepository.addMediaToken(headers: headers());
  }

  Map<String, String> headers() {
    return {HttpHeaders.userAgentHeader: userAgent};
  }

  bool _haveTokens() {
    return tokenRepository.refreshToken != null &&
        tokenRepository.accessToken != null;
  }

  Future<Map<String, dynamic>> _getJson(String uri,
      {bool cacheable = true, Duration? ttl}) async {
    ttl = ttl ?? defaultTTL;
    Map<String, dynamic>? cachedJson;

    if (cacheable) {
      final result = await jsonCacheRepository.get(uri, ttl: ttl);
      if (result.exists) {
        log.d('cached $uri expired is ${result.expired}');
        try {
          cachedJson = await result.read();
        } catch (e) {
          // can't parse cached json, will try to replace it
          log.w('parse failed', error: e);
        }
        if (cachedJson != null && result.expired == false) {
          // not expired so use the cached value
          return cachedJson;
        }
      }
    }

    try {
      final response = await _client
          .get(Uri.parse('$endpoint$uri'), headers: _headersWithAccessToken())
          .timeout(defaultTimeout);
      log.d('got ${response.statusCode}');
      if (response.statusCode != HttpStatus.ok) {
        if (response.statusCode >= HttpStatus.internalServerError &&
            cachedJson != null) {
          return cachedJson;
        }
        throw ClientException(
            statusCode: response.statusCode,
            url: response.request?.url.toString());
      }
      log.t('got response ${response.body}');
      if (cacheable) {
        await jsonCacheRepository.put(uri, response.bodyBytes);
      }
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (e, stackTrace) {
      if (e is SocketException || e is TimeoutException || e is TlsException) {
        if (cachedJson != null) {
          log.w('using cached json', error: e);
          return cachedJson;
        }
      }
      return Future<Map<String, dynamic>>.error(e, stackTrace);
    }
  }

  Future<void> _delete(String uri) async {
    return _method('DELETE', uri);
  }

  Future<void> _put(String uri) async {
    return _method('PUT', uri);
  }

  // call a method w/o any input or output data.
  Future<void> _method(String method, String uri) async {
    final token = tokenRepository.accessToken;
    if (token == null) {
      throw const ClientException(
        statusCode: HttpStatus.networkAuthenticationRequired,
      );
    }

    try {
      http.Response response;
      if (method == 'DELETE') {
        response = await _client.delete(Uri.parse('$endpoint$uri'),
            headers: _headersWithAccessToken());
      } else if (method == 'PUT') {
        response = await _client.put(Uri.parse('$endpoint$uri'),
            headers: _headersWithAccessToken());
      } else {
        throw const ClientException(statusCode: HttpStatus.badRequest);
      }
      log.d('got ${response.statusCode}');
      switch (response.statusCode) {
        case HttpStatus.accepted:
        case HttpStatus.noContent:
        case HttpStatus.ok:
          // success
          await jsonCacheRepository.invalidate(uri);
          break;
        default:
          // failure
          throw ClientException(
              statusCode: response.statusCode,
              url: response.request?.url.toString());
      }
    } on TlsException catch (e) {
      return Future.error(e);
    }
  }

  /// no caching
  Future<Map<String, dynamic>> _postJson(String uri, Map<String, dynamic> json,
      {bool requireAuth = false}) async {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: ContentType.json.toString()
    };

    if (requireAuth) {
      final token = tokenRepository.accessToken;
      if (token == null) {
        throw const ClientException(
          statusCode: HttpStatus.networkAuthenticationRequired,
        );
      }
      headers.addAll(_headersWithAccessToken());
    }

    log.t(jsonEncode(json));
    try {
      final response = await _client
          .post(Uri.parse('$endpoint$uri'),
              headers: headers, body: jsonEncode(json))
          .timeout(defaultTimeout);
      log.d('response ${response.statusCode}');
      if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.noContent) {
        throw ClientException(
            statusCode: response.statusCode,
            url: response.request?.url.toString());
      }
      if (response.body.isEmpty) {
        return <String, dynamic>{
          'reasonPhrase': response.reasonPhrase,
          'statusCode': response.statusCode
        };
      } else {
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      }
    } catch (e, stackTrace) {
      return Future<Map<String, dynamic>>.error(e, stackTrace);
    }
  }

  /// no caching
  Future<PatchResult> _patchJson(
      String uri, List<Map<String, dynamic>> json) async {
    final token = tokenRepository.accessToken;
    if (token == null) {
      return Future.error(const ClientException(
        statusCode: HttpStatus.networkAuthenticationRequired,
      ));
    }

    log.t(jsonEncode(json));
    final headers = _headersWithAccessToken();
    headers[HttpHeaders.contentTypeHeader] = 'application/json-patch+json';
    return _client
        .patch(Uri.parse('$endpoint$uri'),
            headers: headers, body: jsonEncode(json))
        .then((response) {
      log.d('response ${response.statusCode}');
      if (response.statusCode == HttpStatus.ok) {
        jsonCacheRepository.invalidate(uri); // async
        return PatchResult(
            HttpStatus.ok,
            jsonDecode(utf8.decode(response.bodyBytes))
                as Map<String, dynamic>);
      } else if (response.statusCode == HttpStatus.noContent) {
        return PatchResult(HttpStatus.noContent, <String, dynamic>{});
      } else {
        return Future.error(ClientException(
            statusCode: response.statusCode,
            url: response.request?.url.toString()));
      }
    });
  }

  /// POST /api/token
  @override
  Future<bool> login(String user, String pass, {String? passcode}) async {
    var success = false;
    final json = {'User': user, 'Pass': pass};
    if (passcode != null) {
      json['Passcode'] = passcode;
    }
    try {
      final result = await _postJson('/api/token', json);
      log.t(result);
      if (result.containsKey(fieldAccessToken) &&
          result.containsKey(fieldMediaToken) &&
          result.containsKey(fieldRefreshToken)) {
        tokenRepository.add(
            accessToken: result[fieldAccessToken] as String,
            mediaToken: result[fieldMediaToken] as String,
            refreshToken: result[fieldRefreshToken] as String);
        success = true;
      }
      return success;
    } on ClientException {
      return false;
    }
  }

  /// POST /api/link
  @override
  Future<bool> link({
    required String code,
    required String user,
    required String password,
    String? passcode,
  }) async {
    const uri = '/api/link';
    var success = false;
    final json = {'Code': code, 'User': user, 'Pass': password};
    if (passcode != null) {
      json['Passcode'] = passcode;
    }
    try {
      final result = await _postJson(uri, json);
      log.d(result);
      if (result['statusCode'] == HttpStatus.noContent) {
        success = true;
      }
      return success;
    } on ClientException {
      return false;
    }
  }

  /// GET /api/code
  /// Request a code for external authorization. This returns a code and access token.
  /// After extern authorization, POST the code with access token to authorize.
  @override
  Future<AccessCode> code() async {
    const uri = '/api/code';
    try {
      final response = await _client.get(Uri.parse('$endpoint$uri'));
      log.d('got ${response.statusCode}');
      if (response.statusCode == 200) {
        final result =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return AccessCode.fromJson(result);
      }
      return Future.error(CodeError());
    } catch (e) {
      return Future.error(e);
    }
  }

  /// POST /api/code
  /// Send the code with access token to complete authorization.
  /// If this successful, the resulting tokens are stored and client is authorized.
  /// If not successful, try again.
  /// InvalidCodeError is returned if the code is invalid or expired.
  @override
  Future<bool> checkCode(AccessCode accessCode) async {
    const uri = '/api/code';
    bool success = false;
    try {
      final headers = {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: 'Bearer ${accessCode.accessToken}',
      };
      final body = jsonEncode(Code(code: accessCode.code).toJson());
      final response = await _client.post(
        Uri.parse('$endpoint$uri'),
        body: body,
        headers: headers,
      );
      log.d('got ${response.statusCode}');
      if (response.statusCode == 200) {
        final result =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        log.t(result);
        if (result.containsKey(fieldAccessToken) &&
            result.containsKey(fieldMediaToken) &&
            result.containsKey(fieldRefreshToken)) {
          tokenRepository.add(
              accessToken: result[fieldAccessToken] as String,
              mediaToken: result[fieldMediaToken] as String,
              refreshToken: result[fieldRefreshToken] as String);
          success = true;
        }
      } else if (response.statusCode == 403) {
        // 403 code not linked yet, can try again
        success = false;
      } else {
        // 401 code is bad or expired
        return Future.error(InvalidCodeError());
      }
    } on TlsException catch (e) {
      return Future.error(e);
    }
    return success;
  }

  /// GET /api/token
  Future<bool> _refreshAccessToken() async {
    const uri = '/api/token';
    bool success = false;
    try {
      final response = await _client.get(Uri.parse('$endpoint$uri'),
          headers: _headersWithRefreshToken());
      log.d('got ${response.statusCode}');
      if (response.statusCode == 200) {
        final result =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        log.t(result);
        if (result.containsKey(fieldAccessToken) &&
            result.containsKey(fieldRefreshToken)) {
          tokenRepository.add(
              accessToken: result[fieldAccessToken] as String,
              refreshToken: result[fieldRefreshToken] as String);
          success = true;
        }
      }
    } on TlsException catch (e) {
      return Future.error(e);
    }
    return success;
  }

  Future<T> _retry<T>(FutureGenerator<T> aFuture) async {
    try {
      return await aFuture();
    } catch (e, stackTrace) {
      if (e is ClientException && e.authenticationFailed && _haveTokens()) {
        // have refresh token, try to refresh access token
        final result = await _refreshAccessToken();
        log.d('in retry result is $result');
        if (result == true) {
          return await aFuture();
        }
      }
      log.w('retry error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// GET /api/search?q=query (no cache by default)
  @override
  Future<SearchView> search(String q, {Duration? ttl = Duration.zero}) async =>
      _retry<SearchView>(() =>
          _getJson('/api/search?q=${Uri.encodeQueryComponent(q)}', ttl: ttl)
              .then((j) => SearchView.fromJson(j))
              .catchError((Object e) => Future<SearchView>.error(e)));

  /// GET /api/index
  @override
  Future<IndexView> index({Duration? ttl}) async =>
      _retry<IndexView>(() => _getJson('/api/index', ttl: ttl)
          .then((j) => IndexView.fromJson(j))
          .catchError((Object e) => Future<IndexView>.error(e)));

  /// GET /api/home
  @override
  Future<HomeView> home({Duration? ttl}) async =>
      _retry<HomeView>(() => _getJson('/api/home', ttl: ttl)
          .then((j) => HomeView.fromJson(j))
          .catchError((Object e) => Future<HomeView>.error(e)));

  /// GET /api/artists
  @override
  Future<ArtistsView> artists({Duration? ttl}) async =>
      _retry<ArtistsView>(() => _getJson('/api/artists', ttl: ttl)
          .then((j) => ArtistsView.fromJson(j))
          .catchError((Object e) => Future<ArtistsView>.error(e)));

  /// GET /api/artists/1
  @override
  Future<ArtistView> artist(int id, {Duration? ttl}) async =>
      _retry<ArtistView>(() => _getJson('/api/artists/$id', ttl: ttl)
          .then((j) => ArtistView.fromJson(j))
          .catchError((Object e) => Future<ArtistView>.error(e)));

  /// GET /api/artists/1/singles
  @override
  Future<SinglesView> artistSingles(int id, {Duration? ttl}) async =>
      _retry<SinglesView>(() => _getJson('/api/artists/$id/singles', ttl: ttl)
          .then((j) => SinglesView.fromJson(j))
          .catchError((Object e) => Future<SinglesView>.error(e)));

  /// GET /api/artists/1/singles/playlist
  @override
  Future<Spiff> artistSinglesPlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/artists/$id/singles/playlist', ttl: ttl);

  /// GET /api/artists/1/popular
  @override
  Future<PopularView> artistPopular(int id, {Duration? ttl}) async =>
      _retry<PopularView>(() => _getJson('/api/artists/$id/popular', ttl: ttl)
          .then((j) => PopularView.fromJson(j))
          .catchError((Object e) => Future<PopularView>.error(e)));

  /// GET /api/artists/1/popular/playlist
  @override
  Future<Spiff> artistPopularPlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/artists/$id/popular/playlist', ttl: ttl);

  /// GET /api/artists/1/playlist
  @override
  Future<Spiff> artistPlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/artists/$id/playlist', ttl: ttl);

  /// GET /api/artists/1/radio/playlist
  @override
  Future<Spiff> artistRadio(int id, {Duration? ttl}) async =>
      spiff('/api/artists/$id/radio/playlist', ttl: ttl);

  /// GET /api/artists/1/wantlist
  @override
  Future<WantListView> artistWantList(int id, {Duration? ttl}) async =>
      _retry<WantListView>(() => _getJson('/api/artists/$id/wantlist', ttl: ttl)
          .then((j) => WantListView.fromJson(j))
          .catchError((Object e) => Future<WantListView>.error(e)));

  /// GET /api/releases/1
  @override
  Future<ReleaseView> release(int id, {Duration? ttl}) async =>
      _retry<ReleaseView>(() => _getJson('/api/releases/$id', ttl: ttl)
          .then((j) => ReleaseView.fromJson(j))
          .catchError((Object e) => Future<ReleaseView>.error(e)));

  /// GET /api/releases/1/playlist
  @override
  Future<Spiff> releasePlaylist(String id, {Duration? ttl}) async =>
      spiff('/api/releases/$id/playlist', ttl: ttl);

  /// GET /api/tracks/1/playlist
  @override
  Future<Spiff> trackPlaylist(String id, {Duration? ttl}) async =>
      spiff('/api/tracks/$id/playlist', ttl: ttl);

  /// GET /api/playlist
  /// GET /api/playlists/1/playlist
  /// GET /api/playlists/name/playlist
  @override
  Future<Spiff> playlist(
      {Duration? ttl = playlistTTL, int? id, String? name}) async {
    if (id != null) {
      return spiff('/api/playlists/$id/playlist', ttl: ttl);
    } else if (name != null) {
      return spiff('/api/playlists/${Uri.encodeComponent(name)}/playlist',
          ttl: ttl);
    } else {
      return spiff(defaultPlaylist, ttl: ttl);
    }
  }

  /// GET /api/playlists
  @override
  Future<PlaylistsView> playlists({Duration? ttl}) async =>
      _retry<PlaylistsView>(() => _getJson('/api/playlists', ttl: ttl)
          .then((j) => PlaylistsView.fromJson(j))
          .catchError((Object e) => Future<PlaylistsView>.error(e)));

  /// POST /api/playlists
  @override
  Future<PlaylistView> createPlaylist(Spiff spiff) async {
    try {
      log.t('createPlaylist $spiff');
      final result = await _retry(
          () => _postJson('/api/playlists', spiff.toJson(), requireAuth: true));
      log.t('createPlaylist got $result');
      await jsonCacheRepository.invalidate('/api/playlists');
      return PlaylistView.fromJson(result);
    } on ClientException {
      return Future.error(HttpStatus.badRequest); // TODO should this throw instead?
    }
  }

  /// PATCH /api/playlists/1/playlist
  @override
  Future<PatchResult> patchPlaylist(
          PlaylistView playlist, List<Map<String, dynamic>> body) async =>
      _retry<PatchResult>(() {
        return _patchJson('/api/playlists/${playlist.id}/playlist', body)
            .then((result) {
          if (result.statusCode == HttpStatus.ok) {
            jsonCacheRepository.invalidate('/api/playlists');
          }
          return result;
        });
      });

  /// DELETE /api/playlists/1
  @override
  Future<void> deletePlaylist(PlaylistView playlist) async =>
      _retry<void>(() => _delete('/api/playlists/${playlist.id}')
              .then((_) => jsonCacheRepository.invalidate('/api/playlists')))
          .catchError((Object e) => Future<void>.error(e));

  /// GET /api/radio
  @override
  Future<RadioView> radio({Duration? ttl}) async =>
      _retry<RadioView>(() => _getJson('/api/radio', ttl: ttl)
          .then((j) => RadioView.fromJson(j))
          .catchError((Object e) => Future<RadioView>.error(e)));

  /// GET /api/stations/1
  @override
  Future<Spiff> station(int id, {Duration? ttl}) async =>
      spiff('/api/stations/$id/playlist', ttl: ttl);

  /// GET /path -> spiff
  Future<Spiff> spiff(String path, {Duration? ttl}) async =>
      _retry<Spiff>(() => _getJson(path, ttl: ttl)
          .then((j) => Spiff.fromJson(j))
          .catchError((Object e) => Future<Spiff>.error(e)));

  @override
  Future<PatchResult> patch(List<Map<String, dynamic>> body) async =>
      _retry<PatchResult>(() => _patchJson(defaultPlaylist, body));

  /// GET /api/movies
  @override
  Future<MoviesView> movies({Duration? ttl}) async =>
      _retry<MoviesView>(() => _getJson('/api/movies', ttl: ttl)
          .then((j) => MoviesView.fromJson(j))
          .catchError((Object e) => Future<MoviesView>.error(e)));

  /// GET /api/movie-genres/name
  @override
  Future<GenreView> moviesGenre(String genre, {Duration? ttl}) async =>
      _retry<GenreView>(() =>
          _getJson('/api/movie-genres/${Uri.encodeComponent(genre)}', ttl: ttl)
              .then((j) => GenreView.fromJson(j))
              .catchError((Object e) => Future<GenreView>.error(e)));

  /// GET /api/movies/1
  @override
  Future<MovieView> movie(int id, {Duration? ttl}) async =>
      _retry<MovieView>(() => _getJson('/api/movies/$id', ttl: ttl)
          .then((j) => MovieView.fromJson(j))
          .catchError((Object e) => Future<MovieView>.error(e)));

  /// GET /api/movies/1/playlist
  @override
  Future<Spiff> moviePlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/movies/$id/playlist', ttl: ttl);

  /// GET /api/tv
  @override
  Future<TVListView> tvList({Duration? ttl}) async =>
      _retry<TVListView>(() => _getJson('/api/tv', ttl: ttl)
          .then((j) => TVListView.fromJson(j))
          .catchError((Object e) => Future<TVListView>.error(e)));

  /// GET /api/tv/series
  @override
  Future<TVShowsView> shows({Duration? ttl}) async =>
      _retry<TVShowsView>(() => _getJson('/api/tv/series', ttl: ttl)
          .then((j) => TVShowsView.fromJson(j))
          .catchError((Object e) => Future<TVShowsView>.error(e)));

  /// GET /api/tv/series/1
  @override
  Future<TVSeriesView> tvSeries(int id, {Duration? ttl}) async =>
      _retry<TVSeriesView>(() => _getJson('/api/tv/series/$id', ttl: ttl)
          .then((j) => TVSeriesView.fromJson(j))
          .catchError((Object e) => Future<TVSeriesView>.error(e)));

  /// GET /api/tv/series/1/playlist
  @override
  Future<Spiff> tvSeriesPlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/tv/series/$id/playlist', ttl: ttl);

  /// GET /api/tv/episodes/1
  @override
  Future<TVEpisodeView> tvEpisode(int id, {Duration? ttl}) async =>
      _retry<TVEpisodeView>(() => _getJson('/api/tv/episodes/$id', ttl: ttl)
          .then((j) => TVEpisodeView.fromJson(j))
          .catchError((Object e) => Future<TVEpisodeView>.error(e)));

  /// GET /api/tv/episodes/1/playlist
  @override
  Future<Spiff> tvEpisodePlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/tv/episodes/$id/playlist', ttl: ttl);

  /// GET /api/profiles/1
  @override
  Future<ProfileView> profile(int peid, {Duration? ttl}) async =>
      _retry<ProfileView>(() => _getJson('/api/profiles/$peid', ttl: ttl)
          .then((j) => ProfileView.fromJson(j))
          .catchError((Object e) => Future<ProfileView>.error(e)));

  /// GET /api/podcasts
  @override
  Future<PodcastsView> podcasts({Duration? ttl}) async =>
      _retry<PodcastsView>(() => _getJson('/api/podcasts', ttl: ttl)
          .then((j) => PodcastsView.fromJson(j))
          .catchError((Object e) => Future<PodcastsView>.error(e)));

  /// GET /api/podcasts/subscribed
  @override
  Future<PodcastsView> podcastsSubscribed({Duration? ttl}) async =>
      _retry<PodcastsView>(() => _getJson('/api/podcasts/subscribed', ttl: ttl)
          .then((j) => PodcastsView.fromJson(j))
          .catchError((Object e) => Future<PodcastsView>.error(e)));

  /// GET /api/series/1
  @override
  Future<SeriesView> series(int id, {Duration? ttl}) async =>
      _retry<SeriesView>(() => _getJson('/api/series/$id', ttl: ttl)
          .then((j) => SeriesView.fromJson(j))
          .catchError((Object e) => Future<SeriesView>.error(e)));

  /// PUT /api/series/1/subscribed
  @override
  Future<void> seriesSubscribe(int id) async =>
      _retry<void>(() => _put('/api/series/$id/subscribed')
          .catchError((Object e) => Future<void>.error(e)));

  /// DELETE /api/series/1/subscribed
  @override
  Future<void> seriesUnsubscribe(int id) async =>
      _retry<void>(() => _delete('/api/series/$id/subscribed')
          .catchError((Object e) => Future<void>.error(e)));

  /// GET /api/series/1/playlist
  @override
  Future<Spiff> seriesPlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/series/$id/playlist', ttl: ttl);

  /// GET /api/episodes/1
  Future<EpisodeView> episode(int id, {Duration? ttl}) async =>
      _getJson('/api/episodes/$id', ttl: ttl)
          .then((j) => EpisodeView.fromJson(j))
          .catchError((Object e) => Future<EpisodeView>.error(e));

  /// GET /api/episodes/1/playlist
  @override
  Future<Spiff> episodePlaylist(int id, {Duration? ttl}) async =>
      spiff('/api/episodes/$id/playlist', ttl: ttl);

  /// GET /api/progress
  @override
  Future<ProgressView> progress({Duration? ttl}) async =>
      _retry<ProgressView>(() => _getJson('/api/progress', ttl: ttl)
          .then((j) => ProgressView.fromJson(j))
          .catchError((Object e) => Future<ProgressView>.error(e)));

  /// POST /api/progress
  @override
  Future<int> updateProgress(Offsets offsets) async {
    try {
      log.t('updateProgress $offsets');
      final result = await _retry(() =>
          _postJson('/api/progress', offsets.toJson(), requireAuth: true));
      log.t('updateProgress got $result');
      return result['statusCode'] as int;
    } on ClientException {
      return HttpStatus.badRequest; // TODO should this throw instead?
    }
  }

// Future deleteProgress(Offset offset) async {
//   return _retry(() => _delete('/api/progress/${offset.id}'));
// }

  /// GET /api/activity/tracks/interval
  @override
  Future<TrackStatsView> trackStats({
    Duration? ttl,
    IntervalType? interval,
  }) async =>
      _retry<TrackStatsView>(() {
        final i = interval ?? IntervalType.today;
        return _getJson('/api/activity/tracks/${i.name}/stats', ttl: ttl)
            .then((j) => TrackStatsView.fromJson(j))
            .catchError((Object e) => Future<TrackStatsView>.error(e));
      });

  /// POST /api/activity
  @override
  Future<int> updateActivity(Events events) async {
    log.t('updateActivity $events');
    final result = await _retry(
        () => _postJson('/api/activity', events.toJson(), requireAuth: true));
    log.t('updateActivity got $result');
    return result['statusCode'] as int;
  }

  /// GET /api/activity/tracks/recent
  @override
  Future<TrackHistoryView> recentTracks({Duration? ttl}) async =>
      _getJson('/api/activity/tracks/recent', ttl: ttl)
          .then((j) => TrackHistoryView.fromJson(j))
          .catchError((Object e) => Future<TrackHistoryView>.error(e));

  /// GET /api/activity/tracks/recent/playlist
  @override
  Future<Spiff> recentTracksPlaylist({Duration? ttl}) async =>
      spiff('/api/activity/tracks/recent/playlist', ttl: ttl);

  /// GET /api/activity/tracks/popular
  @override
  Future<TrackStatsView> popularTracks({Duration? ttl}) async =>
      _getJson('/api/activity/tracks/popular', ttl: ttl)
          .then((j) => TrackStatsView.fromJson(j))
          .catchError((Object e) => Future<TrackStatsView>.error(e));

  /// GET /api/activity/tracks/popular/playlist
  @override
  Future<Spiff> popularTracksPlaylist({Duration? ttl}) async =>
      spiff('/api/activity/tracks/popular/playlist', ttl: ttl);

  /// Download uri to a file with optional retries.
  @override
  Future<int> download(Uri uri, File file, int size,
      {Sink<int>? progress, int retries = 0}) async {
    for (;;) {
      try {
        return await _retry<int>(
            () => _download(uri, file, size, progress: progress));
      } catch (e) {
        log.w('download failed', error: e);
        if (retries > 0) {
          // try again
          retries--;
          continue;
        }
        rethrow;
      }
    }
  }

  /// Download uri to a file.
  Future<int> _download(Uri uri, File file, int size,
      {Sink<int>? progress}) async {
    final completer = Completer<int>();
    log.d('download file is $file');

    if (uri.hasScheme == false) {
      uri = Uri.parse('$endpoint${uri.toString()}');
    }

    unawaited(HttpClient()
        .getUrl(uri)
        .then((request) async {
          final headers = _headersWithMediaToken();
          headers.forEach((k, v) {
            request.headers.set(k, v);
          });
          return request.close();
        })
        .then((response) {
          final sink = file.openWrite();
          response.listen((data) {
            sink.add(data);
            if (progress != null) progress.add(data.length);
          }, onDone: () {
            if (progress != null) progress.close();
            sink.flush().whenComplete(() => sink.close().whenComplete(() {
                  final fileSize = file.lengthSync();
                  if (size == fileSize) {
                    completer.complete(size);
                  } else if (fileSize > size) {
                    // unfortunately podcasts can be larger than expected
                    // TODO only allow this for podcasts
                    completer.complete(fileSize);
                  } else {
                    throw _ClientError(
                        '$size (expected) != $fileSize (actual)');
                  }
                }));
          }, onError: (Object err) {
            throw err;
          });
        })
        .timeout(downloadTimeout)
        .catchError((Object e) {
          if (file.existsSync()) {
            file.deleteSync();
          }
          completer.completeError(e);
        }));
    return completer.future;
  }
}
