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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_watch/l10n/app_localizations.dart';
import 'package:takeout_watch/player.dart';

import 'app.dart';

export 'package:takeout_lib/context/context.dart';

extension AppContext on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this)!;

  void logout() {
    tokens.removeAll();
    app.logout();
  }

  AppCubit get app => read<AppCubit>();

  void showPlayer(BuildContext context) => Navigator.push(
      context, CupertinoPageRoute<void>(builder: (_) => const PlayerPage()));

  ListTileThemeData get listTileTheme => Theme.of(this).listTileTheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
