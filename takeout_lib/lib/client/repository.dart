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

import 'dart:io';

import 'package:http/http.dart';
import 'package:takeout_lib/api/client.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/json_repository.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/patch.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/stats.dart';
import 'package:takeout_lib/tokens/repository.dart';

import 'provider.dart';

class ClientRepository {
  final ClientProvider _provider;

  ClientRepository(
      {required SettingsRepository settingsRepository,
      required JsonCacheRepository jsonCacheRepository,
      required TokenRepository tokenRepository,
      String? userAgent,
      ClientProvider? provider})
      : _provider = provider ??
            TakeoutClient(
                userAgent: userAgent,
                settingsRepository: settingsRepository,
                jsonCacheRepository: jsonCacheRepository,
                tokenRepository: tokenRepository);

  Client get client => _provider.client;

  Future<bool> login(String user, String password, {String? passcode}) async {
    return _provider.login(user, password, passcode: passcode);
  }

  Future<bool> link(
      {required String code,
      required String user,
      required String password,
      String? passcode}) async {
    return _provider.link(
        code: code, user: user, password: password, passcode: passcode);
  }

  Future<AccessCode> code() async {
    return _provider.code();
  }

  Future<bool> checkCode(AccessCode accessCode) async {
    return _provider.checkCode(accessCode);
  }

  Future<ArtistsView> artists({Duration? ttl}) async {
    return _provider.artists(ttl: ttl);
  }

  Future<ArtistView> artist(int id, {Duration? ttl}) async {
    return _provider.artist(id, ttl: ttl);
  }

  Future<Spiff> artistRadio(int id, {Duration? ttl}) async {
    return _provider.artistRadio(id, ttl: ttl);
  }

  Future<Spiff> artistPlaylist(int id, {Duration? ttl}) async {
    return _provider.artistPlaylist(id, ttl: ttl);
  }

  Future<PopularView> artistPopular(int id, {Duration? ttl}) async {
    return _provider.artistPopular(id, ttl: ttl);
  }

  Future<Spiff> artistPopularPlaylist(int id, {Duration? ttl}) async {
    return _provider.artistPopularPlaylist(id, ttl: ttl);
  }

  Future<SinglesView> artistSingles(int id, {Duration? ttl}) async {
    return _provider.artistSingles(id, ttl: ttl);
  }

  Future<Spiff> artistSinglesPlaylist(int id, {Duration? ttl}) async {
    return _provider.artistSinglesPlaylist(id, ttl: ttl);
  }

  Future<WantListView> artistWantList(int id, {Duration? ttl}) async {
    return _provider.artistWantList(id, ttl: ttl);
  }

  Future<SearchView> search(String q, {Duration? ttl = Duration.zero}) async {
    return _provider.search(q, ttl: ttl);
  }

  Future<SeriesView> series(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.series(id, ttl: ttl);
  }

  Future<void> seriesSubscribe(int id) async {
    return _provider.seriesSubscribe(id);
  }

  Future<void> seriesUnsubscribe(int id) async {
    return _provider.seriesUnsubscribe(id);
  }

  Future<Spiff> seriesPlaylist(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.seriesPlaylist(id, ttl: ttl);
  }

  Future<Spiff> episodePlaylist(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.episodePlaylist(id, ttl: ttl);
  }

  Future<Spiff> station(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.station(id, ttl: ttl);
  }

  Future<IndexView> index({Duration? ttl}) async {
    return _provider.index(ttl: ttl);
  }

  Future<HomeView> home({Duration? ttl}) async {
    return _provider.home(ttl: ttl);
  }

  Future<MovieView> movie(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.movie(id, ttl: ttl);
  }

  Future<Spiff> moviePlaylist(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.moviePlaylist(id, ttl: ttl);
  }

  Future<GenreView> moviesGenre(String genre,
      {Duration? ttl = Duration.zero}) async {
    return _provider.moviesGenre(genre, ttl: ttl);
  }

  Future<MoviesView> movies({Duration? ttl = Duration.zero}) async {
    return _provider.movies(ttl: ttl);
  }

  Future<TVShowsView> shows({Duration? ttl = Duration.zero}) async {
    return _provider.shows(ttl: ttl);
  }

  Future<TVSeriesView> tvSeries(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.tvSeries(id, ttl: ttl);
  }

  Future<Spiff> tvSeriesPlaylist(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.tvSeriesPlaylist(id, ttl: ttl);
  }

  Future<TVEpisodeView> tvEpisode(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.tvEpisode(id, ttl: ttl);
  }

  Future<Spiff> tvEpisodePlaylist(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.tvEpisodePlaylist(id, ttl: ttl);
  }

  Future<ProfileView> profile(int peid, {Duration? ttl = Duration.zero}) async {
    return _provider.profile(peid, ttl: ttl);
  }

  Future<RadioView> radio({Duration? ttl}) async {
    return _provider.radio(ttl: ttl);
  }

  Future<ReleaseView> release(int id, {Duration? ttl = Duration.zero}) async {
    return _provider.release(id, ttl: ttl);
  }

  Future<Spiff> releasePlaylist(String id, {Duration? ttl}) async {
    return _provider.releasePlaylist(id, ttl: ttl);
  }

  Future<Spiff> trackPlaylist(String id, {Duration? ttl}) async {
    return _provider.trackPlaylist(id, ttl: ttl);
  }

  Future<TrackHistoryView> recentTracks({Duration? ttl}) async {
    return _provider.recentTracks(ttl: ttl);
  }

  Future<TrackStatsView> popularTracks({Duration? ttl}) async {
    return _provider.popularTracks(ttl: ttl);
  }

  Future<int> download(Uri uri, File file, int size,
      {Sink<int>? progress}) async {
    return _provider.download(uri, file, size, progress: progress);
  }

  Future<PatchResult> patch(List<Map<String, dynamic>> body) async {
    return _provider.patch(body);
  }

  Future<Spiff> playlist({Duration? ttl, int? id, String? name}) async {
    return _provider.playlist(id: id, ttl: ttl);
  }

  Future<PlaylistsView> playlists({Duration? ttl}) async {
    return _provider.playlists(ttl: ttl);
  }

  Future<PlaylistView> createPlaylist(Spiff spiff) async {
    return _provider.createPlaylist(spiff);
  }

  Future<PatchResult> patchPlaylist(
      PlaylistView playlist, List<Map<String, dynamic>> body) async {
    return _provider.patchPlaylist(playlist, body);
  }

  Future<void> deletePlaylist(PlaylistView playlist) {
    return _provider.deletePlaylist(playlist);
  }

  Future<ProgressView> progress({Duration? ttl}) async {
    return _provider.progress(ttl: ttl);
  }

  Future<int> updateProgress(Offsets offsets) async {
    return _provider.updateProgress(offsets);
  }

  Future<TrackStatsView> trackStats(
      {Duration? ttl, IntervalType? interval}) async {
    return _provider.trackStats(ttl: ttl, interval: interval);
  }

  Future<int> updateActivity(Events events) async {
    return _provider.updateActivity(events);
  }

  Future<PodcastsView> podcasts({Duration? ttl}) async {
    return _provider.podcasts(ttl: ttl);
  }

  Future<PodcastsView> podcastsSubscribed({Duration? ttl}) async {
    return _provider.podcastsSubscribed(ttl: ttl);
  }

  Future<Spiff?> replace(
    String ref, {
    int index = 0,
    double position = 0.0,
    MediaType mediaType = MediaType.music,
    String? creator = '',
    String? title = '',
  }) async {
    final body =
        patchReplace(ref, mediaType.name, creator: creator, title: title) +
            patchPosition(index, position);
    final result = await patch(body);
    if (result.isModified) {
      return Spiff.fromJson(result.body);
    }
    return null;
  }

  // update current index and position
  Future<Spiff?> playlistUpdate(PlaylistView playlist,
          {int index = 0, double position = 0.0}) async =>
      _doPatch(playlist, patchPosition(index, position));

  // replace contents with new ref
  Future<Spiff?> playlistReplace(PlaylistView playlist, String ref,
          {int index = 0, double position = 0.0}) async =>
      _doPatch(
          playlist,
          patchReplace(ref, MediaType.music.name) +
              patchPosition(index, position));

  // remove track at index
  Future<Spiff?> playlistRemove(PlaylistView playlist, int index) async =>
      _doPatch(playlist, patchRemove(index.toString()));

  // append ref
  Future<Spiff?> playlistAppend(PlaylistView playlist, String ref) async =>
      _doPatch(playlist, patchAppend(ref));

  Future<Spiff?> _doPatch(
      PlaylistView playlist, List<Map<String, dynamic>> body) async {
    final result = await patchPlaylist(playlist, body);
    if (result.isModified) {
      return Spiff.fromJson(result.body);
    }
    return null;
  }
}
