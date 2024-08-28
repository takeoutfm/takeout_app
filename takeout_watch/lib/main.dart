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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:takeout_lib/context/bloc.dart';
import 'package:takeout_watch/app/app.dart';
import 'package:takeout_watch/app/bloc.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'connect.dart';
import 'home.dart';
import 'nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TakeoutBloc.initStorage();

  runApp(const WatchApp());
}

class WatchApp extends StatelessWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = ThemeData.localize(ThemeData.dark(useMaterial3: true),
        context.textTheme.apply(fontSizeFactor: 1.0));

    appTheme = appTheme.copyWith(
        listTileTheme: appTheme.listTileTheme.copyWith(
            titleTextStyle: appTheme.textTheme.bodyMedium
                ?.copyWith(overflow: TextOverflow.ellipsis),
            subtitleTextStyle: appTheme.textTheme.bodySmall
                ?.copyWith(overflow: TextOverflow.ellipsis)),
        visualDensity: VisualDensity.compact,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ));
    // textTheme: appTheme.textTheme.apply(fontSizeFactor: 0.50));

    return AppBloc().init(context,
        child: MaterialApp(
            key: globalAppKey,
            theme: appTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            home: const MainPage()));
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AppBlocState, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    appInitState(context);

    final settings = context.settings.state.settings;
    if (settings.host == 'https://example.com') {
      // TODO need UI to enter host
      context.settings.host = 'https://takeout.fm';
    }
  }

  @override
  void dispose() {
    appDispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.connectivity.check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    return state.authenticated ? HomePage() : const ConnectPage();
  }
}
