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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/spiff/model.dart';

const appVersion = '0.23.3'; // #version#
const appSource = 'https://github.com/takeoutfm/takeout_app';
const appHome = 'https://takeoutfm.com/';

class AppState {
  final bool authenticated;
  final Spiff? nowPlaying;

  AppState(this.nowPlaying, this.authenticated);

  factory AppState.initial() => AppState(null, false);

  AppState copyWith({Spiff? nowPlaying, bool? authenticated}) => AppState(
      nowPlaying ?? this.nowPlaying, authenticated ?? this.authenticated);
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState.initial());

  void authenticated() => emit(state.copyWith(authenticated: true));

  void logout() => emit(state.copyWith(authenticated: false));

  void nowPlaying(Spiff spiff) => emit(state.copyWith(nowPlaying: spiff));
}
