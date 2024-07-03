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

import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/settings/model.dart';
import 'package:takeout_lib/settings/repository.dart';

import 'package:listenbrainz_dart/listenbrainz_dart.dart';

abstract class ListenProvider {
  Future<void> playingNow(MediaTrack track);

  Future<void> listened(MediaTrack track, DateTime listenedAt);
}

class DefaultListenProvider implements ListenProvider {
  SettingsRepository settingsRepository;
  ClientRepository clientRepository;

  DefaultListenProvider(this.settingsRepository, this.clientRepository);

  @override
  Future<void> playingNow(MediaTrack track) async {
    final client = _listenBrainz(settingsRepository.settings);
    await client?.submitPlayingNow(_track(track));
  }

  @override
  Future<void> listened(MediaTrack track, DateTime listenedAt) async {
    final client = _listenBrainz(settingsRepository.settings);
    await client?.submitSingle(_track(track), listenedAt);
  }

  ListenBrainz? _listenBrainz(Settings? settings) {
    if (settings == null || settings.enableListenBrainz == false) {
      return null;
    }
    final token = settings.listenBrainzToken;
    if (token == null || token.isEmpty) {
      return null;
    }
    return ListenBrainz(token, client: clientRepository.client);
  }

  Track _track(MediaTrack track) {
    return Track(
      title: track.title,
      artist: track.creator,
      release: track.album,
    );
  }
}