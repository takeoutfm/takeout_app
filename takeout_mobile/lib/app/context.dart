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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:takeout_mobile/video.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/model.dart';

import 'app.dart';

export 'package:takeout_lib/context/context.dart';

extension AppContext on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this)!;

  void logout() {
    tokens.removeAll();
    app.logout();
  }

  void showMovie(MediaTrack movie) {
    playMovie(this, movie);
  }

  void showArtist(String artist) {
    // app.showArtist(artist);
  }

  AppCubit get app => read<AppCubit>();
}
