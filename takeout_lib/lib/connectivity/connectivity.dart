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

import 'package:bloc/bloc.dart';

import 'provider.dart';
import 'repository.dart';

class ConnectivityState {
  final ConnectivityType type;

  ConnectivityState(this.type);

  bool get wifi => type == ConnectivityType.wifi;

  bool get mobile => type == ConnectivityType.mobile;

  bool get ethernet => type == ConnectivityType.ethernet;

  bool get bluetooth => type == ConnectivityType.bluetooth;

  bool get vpn => type == ConnectivityType.vpn;

  bool get none => type == ConnectivityType.none;

  bool get any =>
      type == ConnectivityType.wifi ||
      type == ConnectivityType.mobile ||
      type == ConnectivityType.bluetooth ||
      type == ConnectivityType.vpn ||
      type == ConnectivityType.ethernet;
}

class ConnectivityChange extends ConnectivityState {
  ConnectivityChange(super.type);
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityRepository repository;
  StreamSubscription<ConnectivityType>? _subscription;

  ConnectivityCubit(this.repository)
      : super(ConnectivityState(ConnectivityType.none)) {
    _init();
  }

  void _emitEvent(ConnectivityType type) {
    if (state.type != type) {
      emit(ConnectivityChange(type));
    } else {
      emit(ConnectivityState(type));
    }
  }

  void _init() {
    _subscription = repository.stream.listen((event) => _emitEvent(event));
    repository.check();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  void check() {
    repository.check().then((event) => _emitEvent(event));
  }
}
