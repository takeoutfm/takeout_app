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

import 'dart:async';

import 'provider.dart';

class ConnectivityRepository {
  final ConnectivityProvider _provider;
  StreamSubscription<ConnectivityType>? _subscription;
  ConnectivityType? _connectivityType;

  ConnectivityRepository({ConnectivityProvider? provider})
      : _provider = provider ?? DefaultConnectivityProvider() {
    _init(_provider.stream);
  }

  void _init(Stream<ConnectivityType> stream) {
    _subscription = stream.listen((event) {
      _connectivityType = event;
    });
    // TODO is this needed?
    // _provider.check().then((value) => _connectivityType = value);
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<ConnectivityType> check() async {
    return _provider.check();
  }

  Stream<ConnectivityType> get stream => _provider.stream;

  ConnectivityType? get connectivity => _connectivityType;
}
