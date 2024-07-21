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

import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:crypto/crypto.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/history/repository.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/media_type/repository.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/subscribed/repository.dart';

/*

This table shows the media hierarchy, managed as a file system
with paths that returns lists of MediaItems that are playable
and non-playable. Podcasts items include progress details.

Support for movie playback is TBD. Not sure right now if it's even possible.

+---------+---------------------------+--------+
|Recent   |/history                   |Grid    |
+---------+---------------------------+--------+
|         |/history/spiffs/{id}       |Playable|
+---------+---------------------------+--------+
|Music    |/music                     |Grid    |
+---------+---------------------------+--------+
|         |/music/releases/{id}/tracks|Playable|
+---------+---------------------------+--------+
|         |/music/radio/stations/{id} |Playable|
+---------+---------------------------+--------+
|Podcasts |/podcasts                  |Grid    |
+---------+---------------------------+--------+
|         |/podcasts/series/{id}      |Grid    |
+---------+---------------------------+--------+
|         |/podcasts/episodes/{id}    |Playable|
+---------+---------------------------+--------+
|Radio    |/radio                     |List    |
+---------+---------------------------+--------+
|         |/radio/genre               |List    |
+---------+---------------------------+--------+
|         |/radio/period              |List    |
+---------+---------------------------+--------+
|         |/radio/other               |List    |
+---------+---------------------------+--------+
|         |/radio/stream              |Grid    |
+---------+---------------------------+--------+
|Artists  |/artists                   |List    |
+---------+---------------------------+--------+
|         |/artists/{id}              |Grid    |
+---------+---------------------------+--------+
|Playlists|/playlists                 |List    |
+---------+---------------------------+--------+
|         |/playlists/{id}            |Playable|
+---------+---------------------------+--------+
|Downloads|/downloads                 |Grid    |
+---------+---------------------------+--------+
|         |/downloads/spiffs/{id}     |Playable|
+---------+---------------------------+--------+
|Movies   |/movies                    |Grid    |
+---------+---------------------------+--------+
|         |/movies/{id}               |Playable|
+---------+---------------------------+--------+

 */

// TYPE: double, a value between 0.0 and 1.0, inclusive. 0.0 indicates no
// completion progress (item is not started) and 1.0 indicates full completion
// progress (item is fully played). Values in between indicate partial progress
// (for example, 0.75 indicates the item is 75% complete).
const extrasKeyCompletionPercentage =
    'androidx.media.MediaItem.Extras.COMPLETION_PERCENTAGE';

const extrasKeyCompletionStatus = 'android.media.extra.PLAYBACK_STATUS';
const extrasValueCompletionStatusNotPlayed = 0;
const extrasValueCompletionStatusPartialPlayed = 1;
const extrasValueCompletionStatusFullyPlayed = 2;

const extrasKeyContentBrowsableStyle =
    'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT';
const extrasKeyContentPlayableStyle =
    'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT';
const extrasKeyContentSingleItemStyle =
    'android.media.browse.CONTENT_STYLE_SINGLE_ITEM_HINT';
const extrasValueContentStyleListItem = 1;
const extrasValueContentStyleGridItem = 2;
const extrasValueContentStyleCategoryListItem = 3;
const extrasValueContentStyleCategoryGridItem = 4;

const extrasGridStyle = {
  extrasKeyContentBrowsableStyle: extrasValueContentStyleGridItem,
  extrasKeyContentPlayableStyle: extrasValueContentStyleGridItem,
};

const extrasGridPlayableStyle = {
  extrasKeyContentPlayableStyle: extrasValueContentStyleGridItem,
};

abstract class MediaProvider {
  Future<List<MediaItem>> getRoot();

  Future<List<MediaItem>> getRecent();

  Future<List<MediaItem>> getChildren(String parentId);

  Future<List<MediaItem>> search(String query, {MediaType? mediaType});

  Future<Spiff?> spiffFromMediaId(String mediaId);

  Future<Spiff?> spiffFromSearch(String query, {MediaType? mediaType});

  Future<Movie?> movieFromMediaId(String mediaId);
}

class DefaultMediaProvider implements MediaProvider {
  final ClientRepository clientRepository;
  final HistoryRepository historyRepository;
  final SettingsRepository settingsRepository;
  final SpiffCacheRepository spiffCacheRepository;
  final MediaTypeRepository mediaTypeRepository;
  final SubscribedRepository subscribedRepository;
  final OffsetCacheRepository offsetCacheRepository;

  DefaultMediaProvider(
      this.clientRepository,
      this.historyRepository,
      this.settingsRepository,
      this.spiffCacheRepository,
      this.mediaTypeRepository,
      this.subscribedRepository,
      this.offsetCacheRepository);

  @override
  Future<List<MediaItem>> getRoot() async {
    final items = <MediaItem>[];
    final index = await clientRepository.index();
    // TODO need to localize these strings. Will need a repository for that
    // since there's no context available here.
    items.add(const MediaItem(
      id: '/history',
      title: 'Recent',
      playable: false,
      extras: extrasGridStyle,
    ));
    if (index.hasMusic) {
      items.add(const MediaItem(
        id: '/music',
        title: 'Music',
        playable: false,
        extras: extrasGridStyle,
      ));
    }
    if (index.hasPodcasts) {
      items.add(const MediaItem(
        id: '/podcasts',
        title: 'Podcasts',
        playable: false,
        extras: extrasGridStyle,
      ));
    }
    if (index.hasMusic) {
      items.add(const MediaItem(
        id: '/radio',
        title: 'Radio',
        playable: false,
      ));
      items.add(const MediaItem(
        id: '/artists',
        title: 'Artists',
        playable: false,
      ));
    }
    if (index.hasPlaylists) {
      items.add(const MediaItem(
        id: '/playlists',
        title: 'Playlists',
        playable: false,
      ));
    }
    final downloads = await spiffCacheRepository.entries;
    if (downloads.isNotEmpty) {
      items.add(const MediaItem(
        id: '/downloads',
        title: 'Downloads',
        playable: false,
        extras: extrasGridStyle,
      ));
    }
    if (index.hasMovies) {
      items.add(const MediaItem(
        id: '/movies',
        title: 'Movies',
        playable: false,
        extras: extrasGridStyle,
      ));
    }
    return items;
  }

  @override
  Future<List<MediaItem>> getRecent() async {
    return _getHistory();
  }

  @override
  Future<List<MediaItem>> getChildren(String parentId) async {
    switch (parentId) {
      case '/':
        return getRoot();
      case '/history':
        return _getHistory();
      case '/music':
        return _getMusic();
      case '/podcasts':
        return _getPodcasts();
      case '/radio':
        return _getRadio();
      case '/artists':
        return _getArtists();
      case '/playlists':
        return _getPlaylists();
      case '/downloads':
        return _getDownloads();
      case '/movies':
        return _getMovies();
      default:
        if (parentId.startsWith('/artists/')) {
          return _getArtist(parentId);
        } else if (parentId.startsWith('/radio/')) {
          return _getStations(parentId);
        } else if (parentId.startsWith('/podcasts/series/')) {
          return _getSeries(parentId);
        }
        return getRoot();
    }
  }

  @override
  Future<List<MediaItem>> search(String query, {MediaType? mediaType}) async {
    final items = <MediaItem>[];
    final results = await _search(query);

    if (mediaType == MediaType.video) {
      for (var m in results.movies ?? <Movie>[]) {
        items.add(await _movie(m));
      }
    } else if (mediaType == MediaType.podcast) {
      for (var s in results.series ?? <Series>[]) {
        items.add(_series(s));
      }
    } else if (mediaType == MediaType.stream) {
      for (var s in results.stations ?? <Station>[]) {
        items.add(_station(s));
      }
    } else {
      // default to music
      for (var a in results.artists ?? <Artist>[]) {
        items.add(_artist(a));
      }
      for (var r in results.releases ?? <Release>[]) {
        items.add(_release(r));
      }
      for (var t in results.tracks ?? <Track>[]) {
        items.add(_track(t));
      }
    }
    return items;
  }

  @override
  Future<Movie?> movieFromMediaId(String mediaId) async {
    Movie? movie;
    if (mediaId.startsWith('/movies/')) {
      final id = int.parse(mediaId.split('/')[2]);
      final view = await clientRepository.movie(id);
      movie = view.movie;
    }
    return movie;
  }

  @override
  Future<Spiff?> spiffFromMediaId(String mediaId) async {
    Spiff? spiff;
    if (mediaId.startsWith('/podcasts/episodes/')) {
      final id = int.parse(mediaId.split('/')[3]);
      spiff = await clientRepository.episodePlaylist(id);
    } else if (mediaId.startsWith('/music/radio/stations/')) {
      final id = int.parse(mediaId.split('/')[4]);
      spiff = await clientRepository.station(id);
    } else if (mediaId.startsWith('/music/releases/')) {
      // /music/releases/id[?index=index]
      // TODO the server should support this
      final parts = mediaId.split('?index=');
      int index = 0;
      if (parts.length == 2) {
        mediaId = parts[0];
        index = int.tryParse(parts[1]) ?? 0;
      }
      final id = mediaId.split('/')[3];
      spiff = await clientRepository.releasePlaylist(id);
      spiff = spiff.copyWith(index: index);
    } else if (mediaId.startsWith('/history/spiffs/')) {
      spiff = await _getHistorySpiff(mediaId);
    } else if (mediaId.startsWith('/downloads/spiffs/')) {
      spiff = await _getDownloadSpiff(mediaId);
    } else if (mediaId.startsWith('/playlists/')) {
      final id = int.parse(mediaId.split('/')[2]);
      spiff = await clientRepository.playlist(id: id);
    }
    return spiff;
  }

  // TODO search isn't tested yet. Not sure how to test with ADB/AA.
  @override
  Future<Spiff?> spiffFromSearch(String query, {MediaType? mediaType}) async {
    final results = await _search(query);
    if (results.hits == 0) {
      return null;
    }

    // matched a single artist
    final artists = results.artists ?? [];
    if (artists.length == 1) {
      // play artist songs
      return await clientRepository.artistPlaylist(artists[0].id);
    }

    // matched a single release
    final releases = results.releases ?? [];
    if (releases.length == 1) {
      // play release
      return await clientRepository.releasePlaylist('${releases[0].id}');
    }

    // TODO add more later
    return null;
  }

  Future<List<MediaItem>> _getPlaylists() async {
    final items = <MediaItem>[];
    final view = await clientRepository.playlists();
    for (var p in view.playlists) {
      items.add(await _playlist(p));
    }
    return items;
  }

  Future<List<MediaItem>> _getDownloads() async {
    final items = <MediaItem>[];
    final downloads = await spiffCacheRepository.entries;
    final entries = List<Spiff>.from(downloads);
    entries.sort((a, b) => a.title.compareTo(b.title));
    for (var d in entries) {
      items.add(await _download(d));
    }
    return items;
  }

  Future<List<MediaItem>> _getHistory() async {
    final items = <MediaItem>[];
    final history = await historyRepository.get();
    final spiffs = List<SpiffHistory>.from(history.spiffs);
    spiffs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    for (var s in spiffs) {
      items.add(await _history(s));
    }
    return items;
  }

  Future<List<MediaItem>> _getMusic() async {
    final items = <MediaItem>[];
    final home = await clientRepository.home();
    for (var r in home.added) {
      items.add(_release(r));
    }
    return items;
  }

  Future<List<MediaItem>> _getArtists() async {
    final items = <MediaItem>[];
    final artists = await clientRepository.artists();
    for (var a in artists.artists) {
      items.add(_artist(a));
    }
    return items;
  }

  Future<List<MediaItem>> _getArtist(String parentId) async {
    final items = <MediaItem>[];
    // /artists/id
    final id = int.parse(parentId.split('/')[2]);
    final artist = await clientRepository.artist(id);
    for (var r in artist.releases) {
      items.add(_release(r));
    }
    return items;
  }

  Future<List<MediaItem>> _getRadio() async {
    final items = <MediaItem>[];
    final radio = await clientRepository.radio();
    if (radio.genre != null) {
      items.add(const MediaItem(
          id: '/radio/genre', title: 'Genres', playable: false));
    }
    if (radio.period != null) {
      items.add(const MediaItem(
          id: '/radio/period', title: 'Decades', playable: false));
    }
    if (radio.other != null) {
      items.add(
          const MediaItem(id: '/radio/other', title: 'Other', playable: false));
    }
    if (radio.stream != null) {
      items.add(const MediaItem(
          id: '/radio/stream', title: 'Streams', playable: false));
    }
    return items;
  }

  Future<List<MediaItem>> _getStations(String parentId) async {
    final items = <MediaItem>[];
    final radio = await clientRepository.radio();
    List<Station>? stations;
    if (parentId == '/radio/genre') {
      stations = radio.genre;
    } else if (parentId == '/radio/period') {
      stations = radio.period;
    } else if (parentId == '/radio/other') {
      stations = radio.other;
    } else if (parentId == '/radio/stream') {
      stations = radio.stream;
    }
    if (stations != null) {
      for (var s in stations) {
        items.add(_station(s));
      }
    }
    return items;
  }

  Future<List<MediaItem>> _getMovies() async {
    final items = <MediaItem>[];
    final home = await clientRepository.home();

    Iterable<Movie>? movies;
    final videoType = mediaTypeRepository.videoType;
    switch (videoType) {
      case VideoType.added:
        movies = home.addedMovies;
      case VideoType.recent:
        movies = home.newMovies;
      case VideoType.recommended:
        final recommended = home.recommendMovies;
        if (recommended != null) {
          movies = recommended.first.movies ?? [];
        }
      case VideoType.all:
        final view = await clientRepository.movies();
        movies = List<Movie>.from(view.movies);
    }

    if (movies != null) {
      for (var m in movies) {
        items.add(await _movie(m));
      }
    }

    return items;
  }

  Future<List<MediaItem>> _getPodcasts() async {
    final items = <MediaItem>[];
    List<Series> series;
    final podcastType = mediaTypeRepository.podcastType;
    if (podcastType == PodcastType.subscribed) {
      series = subscribedRepository.series;
    } else {
      final home = await clientRepository.home();
      if (podcastType == PodcastType.recent) {
        series = home.newSeries ?? [];
      } else {
        // TODO support all
        series = home.newSeries ?? [];
      }
    }
    for (var s in series) {
      items.add(_series(s));
    }
    return items;
  }

  Future<List<MediaItem>> _getSeries(String parentId) async {
    final items = <MediaItem>[];
    // /podcasts/series/id
    final id = int.parse(parentId.split('/')[3]);
    final series = await clientRepository.series(id);
    for (var e in series.episodes) {
      items.add(await _episode(e));
    }
    return items;
  }

  Future<Spiff?> _getHistorySpiff(String mediaId) async {
    final history = await historyRepository.get();
    // /history/spiffs/id
    final id = int.parse(mediaId.split('/')[3]);
    for (var s in history.spiffs) {
      if (s.dateTime.millisecondsSinceEpoch == id) {
        return s.spiff;
      }
    }
    return null;
  }

  Future<Spiff?> _getDownloadSpiff(String mediaId) async {
    final downloads = await spiffCacheRepository.entries;
    // /downloads/spiffs/id
    final id = mediaId.split('/')[3];
    for (var s in downloads) {
      if (_downloadKey(s) == id) {
        return s;
      }
    }
    return null;
  }

  MediaItem _release(Release r) {
    return MediaItem(
        id: '/music/releases/${r.id}/tracks',
        title: r.album,
        artist: r.artist,
        album: r.album,
        artUri: _img(r.image),
        playable: true);
  }

  MediaItem _station(Station s) {
    Map<String, dynamic>? extras;
    if (s.type == 'stream') {
      extras = extrasGridPlayableStyle;
    }
    return MediaItem(
      id: '/music/radio/stations/${s.id}',
      title: s.name,
      artist: s.creator.isNotEmpty ? s.creator : null,
      artUri: s.image.isNotEmpty ? _img(s.image) : null,
      playable: true,
      extras: extras,
    );
  }

  MediaItem _series(Series s) {
    return MediaItem(
        id: '/podcasts/series/${s.id}',
        title: s.title,
        artUri: _img(s.image),
        playable: false);
  }

  Future<Map<String, dynamic>> _completionExtras(OffsetIdentifier id) async {
    final offset = await offsetCacheRepository.get(id);
    final completionPercentage = offset?.value();
    var completionStatus = extrasValueCompletionStatusNotPlayed;

    if (completionPercentage != null) {
      if (completionPercentage >= 95) {
        completionStatus = extrasValueCompletionStatusFullyPlayed;
      } else if (completionPercentage > 0) {
        completionStatus = extrasValueCompletionStatusPartialPlayed;
      }
    }

    return {
      if (completionPercentage != null)
        extrasKeyCompletionPercentage: completionPercentage,
      extrasKeyCompletionStatus: completionStatus,
    };
  }

  Future<MediaItem> _episode(Episode e) async {
    final extras = await _completionExtras(e);
    // no effect?
    // extras[extrasKeyContentPlayableStyle] = extrasValueContentStyleGridItem;
    return MediaItem(
      id: '/podcasts/episodes/${e.id}',
      title: e.title,
      artist: e.author,
      artUri: _img(e.image),
      playable: true,
      extras: extras,
    );
  }

  MediaItem _artist(Artist a) {
    return MediaItem(
      id: '/artists/${a.id}',
      title: a.name,
      playable: false,
      extras: {
        // use grid for artist releases
        extrasKeyContentBrowsableStyle: extrasValueContentStyleGridItem,
        extrasKeyContentPlayableStyle: extrasValueContentStyleGridItem,
      },
    );
  }

  Future<Map<String, dynamic>?> _spiffExtras(Spiff spiff) async {
    Map<String, dynamic>? extras;

    if (spiff.isPodcast() && spiff.length == 1) {
      final episode = spiff[0];
      extras = await _completionExtras(episode);
    }

    return extras;
  }

  Future<MediaItem> _history(SpiffHistory h) async {
    return MediaItem(
        id: '/history/spiffs/${h.dateTime.millisecondsSinceEpoch}',
        title: h.spiff.title,
        artUri: _img(h.spiff.cover),
        playable: true,
        extras: await _spiffExtras(h.spiff));
  }

  MediaItem _track(Track t) {
    return MediaItem(
        id: '/music/releases/${t.reid}?index=${t.trackIndex}',
        title: t.title,
        artUri: _img(t.image),
        playable: true);
  }

  Future<MediaItem> _movie(Movie m) async {
    return MediaItem(
      id: '/movies/${m.id}',
      title: m.title,
      artUri: _img(m.image),
      playable: true,
      extras: await _completionExtras(m),
    );
  }

  String _md5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String _downloadKey(Spiff spiff) {
    return _md5('${spiff.location}${spiff.date}');
  }

  Future<MediaItem> _download(Spiff spiff) async {
    return MediaItem(
      id: '/downloads/spiffs/${_downloadKey(spiff)}',
      title: spiff.title,
      artUri: _img(spiff.cover),
      playable: true,
      extras: await _spiffExtras(spiff),
    );
  }

  Future<MediaItem> _playlist(PlaylistView playlist) async {
    return MediaItem(
      id: '/playlists/${playlist.id}',
      title: playlist.name,
      playable: true,
    );
  }

  Uri _img(String i) {
    final endpoint = settingsRepository.settings?.endpoint;
    if (i.startsWith('/img/')) {
      i = '$endpoint$i';
    }
    return Uri.parse(i);
  }

  Future<SearchView> _search(String query) async {
    return await clientRepository.search(query);
  }
}
