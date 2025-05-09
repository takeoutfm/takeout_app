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

import 'package:audio_service/audio_service.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/browser/provider.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/track_repository.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/db/search.dart';
import 'package:takeout_lib/history/repository.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/media_type/repository.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/subscribed/repository.dart';

abstract class MediaPlayer {
  void playSpiff(Spiff spiff);

  void playMovie(Movie movie);
}

class MediaRepository {
  final MediaProvider _provider;
  MediaPlayer? _player;

  MediaRepository(
      {required ClientRepository clientRepository,
      required HistoryRepository historyRepository,
      required SettingsRepository settingsRepository,
      required SpiffCacheRepository spiffCacheRepository,
      required MediaTypeRepository mediaTypeRepository,
      required SubscribedRepository subscribedRepository,
      required OffsetCacheRepository offsetCacheRepository,
      required TrackCacheRepository trackCacheRepository,
      required Search searchRepository,
      MediaProvider? provider})
      : _provider = provider ??
            DefaultMediaProvider(
              clientRepository,
              historyRepository,
              settingsRepository,
              spiffCacheRepository,
              mediaTypeRepository,
              subscribedRepository,
              offsetCacheRepository,
              trackCacheRepository,
              searchRepository,
            );

  void init(MediaPlayer player) {
    _player = player;
  }

  bool getSearchSupported() {
    return true;
  }

  Future<List<MediaItem>> getRoot() async {
    return _provider.getRoot();
  }

  Future<List<MediaItem>> getRecent() async {
    return _provider.getRecent();
  }

  Future<List<MediaItem>> getChildren(String parentId) async {
    return _provider.getChildren(parentId);
  }

  Future<List<MediaItem>> search(String query,
      {MediaType? mediaType, Map<String, dynamic>? extras}) async {
    return _provider.search(query, mediaType: mediaType, extras: extras);
  }

  Future<void> playFromMediaId(String mediaId) async {
    final spiff = await _provider.spiffFromMediaId(mediaId);
    if (spiff != null) {
      _player?.playSpiff(spiff);
    } else {
      final movie = await _provider.movieFromMediaId(mediaId);
      if (movie != null) {
        _player?.playMovie(movie);
      }
    }
  }

  Future<void> playFromSearch(String query,
      {MediaType? mediaType, Map<String, dynamic>? extras}) async {
    if (mediaType == MediaType.film) {
      final results = await _provider.search(query, mediaType: mediaType);
      if (results.isNotEmpty) {
        // TODO this plays first result
        final movie = await _provider.movieFromMediaId(results.first.id);
        if (movie != null) {
          _player?.playMovie(movie);
        }
      }
    } else {
      final spiff = await _provider.spiffFromSearch(query,
          mediaType: mediaType, extras: extras);
      if (spiff != null) {
        _player?.playSpiff(spiff);
      }
    }
  }
}
