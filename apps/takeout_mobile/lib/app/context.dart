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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/l10n/app_localizations.dart';
import 'package:takeout_mobile/pages/film.dart';

export 'package:takeout_lib/context/context.dart';

extension AppContext on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this)!;

  TextStyle? get displayLarge => Theme.of(this).textTheme.displayLarge;

  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;

  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;

  TextStyle? get headlineLarge => Theme.of(this).textTheme.headlineLarge;

  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium;

  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;

  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;

  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;

  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;

  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;

  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;

  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;

  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;

  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium;

  TextStyle? get labelSmall => Theme.of(this).textTheme.labelSmall;

  /// used for main headers
  TextStyle? get header1 => headlineMedium;

  /// used for secondary headers
  TextStyle? get header2 => headlineSmall;

  /// used for basic text
  TextStyle? get body => bodyMedium;

  TextStyle? get bodyLink => bodyMedium?.copyWith(decoration: .underline);

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
