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

import 'package:listenbrainz_dart/listenbrainz_dart.dart' as lbz;
import 'package:logger/logger.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/connectivity/repository.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/model.dart';
import 'package:takeout_lib/settings/repository.dart';

import 'retry.dart';

abstract class ListenProvider {
  Future<void> playingNow(MediaTrack track);

  Future<void> listened(MediaTrack track, DateTime listenedAt);
}

class DefaultListenProvider implements ListenProvider {
  static final log = Logger();

  final SettingsRepository settingsRepository;
  final ClientRepository clientRepository;
  final ConnectivityRepository connectivityRepository;
  final List<ListenProvider> _providers;

  DefaultListenProvider(this.settingsRepository, this.clientRepository,
      this.connectivityRepository)
      : _providers = [
          RetryListenProvider(
              'lbz',
              ListenBrainzListenProvider(settingsRepository, clientRepository),
              connectivityRepository),
          RetryListenProvider(
              'tfm',
              TakeoutListenProvider(settingsRepository, clientRepository),
              connectivityRepository),
        ];

  @override
  Future<void> playingNow(MediaTrack track) async {
    for (final p in _providers) {
      try {
        await p.playingNow(track);
      } catch (e, stackTrace) {
        log.w('playingNow failed', error: e, stackTrace: stackTrace);
      }
    }
  }

  @override
  Future<void> listened(MediaTrack track, DateTime listenedAt) async {
    for (final p in _providers) {
      try {
        await p.listened(track, listenedAt);
      } catch (e, stackTrace) {
        log.w('listened failed', error: e, stackTrace: stackTrace);
      }
    }
  }
}

class ListenBrainzListenProvider implements ListenProvider {
  final SettingsRepository settingsRepository;
  final ClientRepository clientRepository;

  ListenBrainzListenProvider(this.settingsRepository, this.clientRepository);

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

  lbz.ListenBrainz? _listenBrainz(Settings? settings) {
    if (settings == null || settings.enableListenBrainz == false) {
      return null;
    }
    final token = settings.listenBrainzToken;
    if (token == null || token.isEmpty) {
      return null;
    }
    return lbz.ListenBrainz(token, client: clientRepository.client);
  }

  lbz.Track _track(MediaTrack track) {
    return lbz.Track(
      title: track.title,
      artist: track.creator,
      release: track.album,
    );
  }
}

class TakeoutListenProvider implements ListenProvider {
  final SettingsRepository settingsRepository;
  final ClientRepository clientRepository;

  TakeoutListenProvider(this.settingsRepository, this.clientRepository);

  @override
  Future<void> playingNow(MediaTrack track) async {
    // not supported
  }

  @override
  Future<void> listened(MediaTrack track, DateTime listenedAt) async {
    if (_sendTrackActivity) {
      return _updateActivity(track, listenedAt);
    }
  }

  bool get _sendTrackActivity =>
      settingsRepository.settings?.enableTrackActivity ?? false;

  Future<void> _updateActivity(MediaTrack track, DateTime listenedAt) {
    final events = Events(
      trackEvents: [
        TrackEvent.from(track.etag, listenedAt),
      ],
    );
    return clientRepository.updateActivity(events);
  }
}
