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

import 'package:audio_service/audio_service.dart';
import 'package:takeout_lib/browser/provider.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/history/repository.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';

abstract class MediaPlayer {
  void play(Spiff spiff);
}

class MediaRepository {
  final MediaProvider _provider;
  MediaPlayer? _player;

  MediaRepository(
      {required ClientRepository clientRepository,
      required HistoryRepository historyRepository,
      required SettingsRepository settingsRepository,
        required SpiffCacheRepository spiffCacheRepository,
      MediaProvider? provider})
      : _provider = provider ??
            DefaultMediaProvider(
                clientRepository, historyRepository, settingsRepository, spiffCacheRepository);

  void init(MediaPlayer player) {
    this._player = player;
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

  Future<List<MediaItem>> search(String query) async {
    return _provider.search(query);
  }

  Future<void> playFromMediaId(String mediaId) async {
    final spiff = await _provider.spiffFromMediaId(mediaId);
    if (spiff != null) {
      _player?.play(spiff);
    }
  }

  Future<void> playFromSearch(String query) async {
    final spiff = await _provider.spiffFromSearch(query);
    if (spiff != null) {
      _player?.play(spiff);
    }
  }
}
