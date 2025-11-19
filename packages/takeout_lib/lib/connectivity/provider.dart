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

import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityType {
  bluetooth,
  wifi,
  ethernet,
  mobile,
  other,
  none;

  bool get isConnected => this != none;
}

abstract class ConnectivityProvider {
  Future<ConnectivityType> check();

  Stream<ConnectivityType> get stream;
}

class DefaultConnectivityProvider implements ConnectivityProvider {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<ConnectivityType> check() async {
    return map(await _connectivity.checkConnectivity());
  }

  @override
  Stream<ConnectivityType> get stream {
    return _connectivity.onConnectivityChanged.map((results) => map(results));
  }

  ConnectivityType map(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityType.none;
    }
    if (results.length == 1 && results.first == .none) {
      return ConnectivityType.none;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return .mobile;
    }
    if (results.contains(ConnectivityResult.wifi)) {
      return .wifi;
    }
    // takeout really only cares about mobile so just return
    // other for anything else
    return .other;
  }
}
