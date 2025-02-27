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

import 'package:takeout_lib/connectivity/repository.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/settings/repository.dart';

import 'provider.dart';

class ListenRepository {
  final ListenProvider _provider;
  final SettingsRepository settingsRepository;
  final ClientRepository clientRepository;
  final ConnectivityRepository connectivityRepository;

  ListenRepository({
    required this.settingsRepository,
    required this.clientRepository,
    required this.connectivityRepository,
    ListenProvider? provider,
  }) : _provider = provider ??
            DefaultListenProvider(
                settingsRepository, clientRepository, connectivityRepository);

  Future<void> playingNow(MediaTrack track) async {
    return _provider.playingNow(track);
  }

  Future<void> listenedAt(MediaTrack track, DateTime listenedAt) async {
    return _provider.listened(track, listenedAt);
  }
}
