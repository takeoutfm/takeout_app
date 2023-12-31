// Copyright 2023 defsub
//
// This file is part of Takeout.
//
// Takeout is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:crypto/crypto.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/history/repository.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/media_type/repository.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/subscribed/repository.dart';

abstract class MediaProvider {
  Future<List<MediaItem>> getRoot();

  Future<List<MediaItem>> getRecent();

  Future<List<MediaItem>> getChildren(String parentId);

  Future<List<MediaItem>> search(String query);

  Future<Spiff?> spiffFromMediaId(String mediaId);

  Future<Spiff?> spiffFromSearch(String query);
}

class DefaultMediaProvider implements MediaProvider {
  final ClientRepository clientRepository;
  final HistoryRepository historyRepository;
  final SettingsRepository settingsRepository;
  final SpiffCacheRepository spiffCacheRepository;
  final MediaTypeRepository mediaTypeRepository;
  final SubscribedRepository subscribedRepository;

  DefaultMediaProvider(
      this.clientRepository,
      this.historyRepository,
      this.settingsRepository,
      this.spiffCacheRepository,
      this.mediaTypeRepository,
      this.subscribedRepository);

  Future<List<MediaItem>> getRoot() async {
    final items = <MediaItem>[];
    final index = await clientRepository.index();
    // TODO need to localize these strings. Will need a repository for that
    // since there's no context available here.
    items.add(MediaItem(id: '/history', title: 'Recent', playable: false));
    if (index.hasMusic) {
      items.add(MediaItem(id: '/music', title: 'Music', playable: false));
    }
    if (index.hasPodcasts) {
      items.add(MediaItem(id: '/podcasts', title: 'Podcasts', playable: false));
    }
    if (index.hasMusic) {
      items.add(MediaItem(id: '/radio', title: 'Radio', playable: false));
      items.add(MediaItem(id: '/artists', title: 'Artists', playable: false));
    }
    final downloads = await spiffCacheRepository.entries;
    if (downloads.isNotEmpty && downloads.any((d) => d.isMusic())) {
      items.add(
          MediaItem(id: '/downloads', title: 'Downloads', playable: false));
    }
    return items;
  }

  Future<List<MediaItem>> getRecent() async {
    return _getHistory();
  }

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
      case '/downloads':
        return _getDownloads();
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

  Future<List<MediaItem>> search(String query) async {
    final items = <MediaItem>[];
    final results = await _search(query);
    for (var a in results.artists ?? []) {
      items.add(_artist(a));
    }
    for (var r in results.releases ?? []) {
      items.add(_release(r));
    }
    for (var t in results.tracks ?? []) {
      items.add(_track(t));
    }
    return items;
  }

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
    }
    return spiff;
  }

  // TODO search isn't tested yet. Not sure how to test.
  Future<Spiff?> spiffFromSearch(String query) async {
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

  Future<List<MediaItem>> _getDownloads() async {
    final items = <MediaItem>[];
    final downloads = await spiffCacheRepository.entries;
    final entries = List<Spiff>.from(downloads);
    entries.sort((a, b) => a.title.compareTo(b.title));
    for (var d in entries) {
      if (d.isMusic()) {
        // FIXME download keys appear to be the same
        items.add(_download(d));
      }
    }
    return items;
  }

  Future<List<MediaItem>> _getHistory() async {
    final items = <MediaItem>[];
    final history = await historyRepository.get();
    final spiffs = List<SpiffHistory>.from(history.spiffs);
    spiffs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    for (var s in spiffs) {
      items.add(_history(s));
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
      items
          .add(MediaItem(id: '/radio/genre', title: 'Genres', playable: false));
    }
    if (radio.period != null) {
      items.add(
          MediaItem(id: '/radio/period', title: 'Decades', playable: false));
    }
    if (radio.other != null) {
      items.add(MediaItem(id: '/radio/other', title: 'Other', playable: false));
    }
    if (radio.stream != null) {
      items.add(
          MediaItem(id: '/radio/stream', title: 'Streams', playable: false));
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
      items.add(_episode(e));
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
    return MediaItem(
        id: '/music/radio/stations/${s.id}', title: s.name, playable: true);
  }

  MediaItem _series(Series s) {
    return MediaItem(
        id: '/podcasts/series/${s.id}',
        title: s.title,
        artUri: _img(s.image),
        playable: false);
  }

  MediaItem _episode(Episode e) {
    return MediaItem(
        id: '/podcasts/episodes/${e.id}',
        title: e.title,
        artist: e.author,
        artUri: _img(e.image),
        playable: true);
  }

  MediaItem _artist(Artist a) {
    return MediaItem(id: '/artists/${a.id}', title: a.name, playable: false);
  }

  MediaItem _history(SpiffHistory h) {
    return MediaItem(
        id: '/history/spiffs/${h.dateTime.millisecondsSinceEpoch}',
        title: h.spiff.title,
        artUri: _img(h.spiff.cover),
        playable: true);
  }

  MediaItem _track(Track t) {
    return MediaItem(
        id: '/music/releases/${t.reid}?index=${t.trackIndex}',
        title: t.title,
        artUri: _img(t.image),
        playable: true);
  }

  String _md5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String _downloadKey(Spiff spiff) {
    return _md5('${spiff.location}${spiff.date}');
  }

  MediaItem _download(Spiff spiff) {
    return MediaItem(
        id: '/downloads/spiffs/${_downloadKey(spiff)}',
        title: spiff.title,
        artUri: _img(spiff.cover),
        playable: true);
  }

  Uri _img(String i) {
    final endpoint = settingsRepository.settings?.endpoint;
    if (i.startsWith('/img/')) {
      i = '$endpoint$i';
    }
    return Uri.parse(i);
  }

  Future<SearchView> _search(String query) async {
    if (query.contains(RegExp(r'[:"\\*]')) == false) {
      query =
          "title:\"$query*\" release:\"$query*\" artist:\"$query*\" genre:\"$query*\"";
    }
    return await clientRepository.search(query);
  }
}
