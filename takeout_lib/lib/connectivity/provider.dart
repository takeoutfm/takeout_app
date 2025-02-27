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
  none,
  vpn;

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
    return _connectivity.onConnectivityChanged.map((result) => map(result));
  }

  ConnectivityType map(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
        return ConnectivityType.bluetooth;
      case ConnectivityResult.wifi:
        return ConnectivityType.wifi;
      case ConnectivityResult.ethernet:
        return ConnectivityType.ethernet;
      case ConnectivityResult.mobile:
        return ConnectivityType.mobile;
      case ConnectivityResult.vpn:
        return ConnectivityType.vpn;
      default:
        return ConnectivityType.none;
    }
  }
}
