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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger/logger.dart';
import 'package:takeout_lib/context/bloc.dart';
import 'package:takeout_lib/log/basic_printer.dart';
import 'package:takeout_lib/video/player.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/desktop.dart';
import 'package:takeout_mobile/l10n/app_localizations.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/takeout.dart';
import 'package:takeout_mobile/widgets/fab.dart';
import 'package:dpad/dpad.dart';

void main() async {
  // setup the logger
  Logger.level = Level.debug;
  Logger.defaultFilter = () => ProductionFilter();
  Logger.defaultPrinter = () => BasicPrinter();

  WidgetsFlutterBinding.ensureInitialized();
  VideoPlayer.init();

  await TakeoutBloc.initStorage();

  runApp(const TakeoutApp());
}

final _desktopKey = GlobalKey<TakeoutState<TakeoutDesktopWidget>>();
final _mobileKey = GlobalKey<TakeoutState<TakeoutMobileState>>();

class TakeoutApp extends StatelessWidget {
  const TakeoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBloc().init(
      context,
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final light = ThemeData.light(useMaterial3: true);
          final dark = ThemeData.dark(useMaterial3: true);
          return OrientationBuilder(
            builder: (context, orientation) {
              final index = context.app.state.index;
              if (orientation == .portrait) {
                context.app.home();
                // if (TakeoutMobileState.navigationIndices.contains(index) ==
                //     false) {
                //   context.app.home();
                // }
              } else {
                // context.app.music();
                // if (TakeoutDesktopState.navigationIndices.contains(index) ==
                //     false) {
                //   context.app.music();
                // }
              }
              final home = orientation == .landscape
                  ? TakeoutDesktopWidget(key: _desktopKey)
                  : TakeoutMobileWidget(key: _mobileKey);

              return MaterialApp(
                key: globalAppKey,
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => context.strings.takeoutTitle,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en', '')],
                builder: Dpad.wrap(
                  onBack: () {
                    final handled = orientation == .landscape
                        ? (_desktopKey.currentState?.handleBack() ?? false)
                        : (_mobileKey.currentState?.handleBack() ?? false);
                    return handled;
                  },
                  shortcuts: {
                    LogicalKeyboardKey.play: () => context.player.toggle(),
                    LogicalKeyboardKey.pause: () => context.player.toggle(),
                  },
                ),
                home: home,
                theme: light.copyWith(
                  colorScheme: lightDynamic,
                  // appBarTheme:
                  //     light.appBarTheme.copyWith(iconTheme: light.iconTheme),
                  // iconButtonTheme: IconButtonThemeData(
                  //     style: IconButton.styleFrom(
                  //         foregroundColor: light.iconTheme.color)),
                  listTileTheme: light.listTileTheme.copyWith(
                    iconColor: light.iconTheme.color,
                  ),
                ),
                darkTheme: dark.copyWith(
                  colorScheme: darkDynamic,
                  // appBarTheme: dark.appBarTheme.copyWith(iconTheme: dark.iconTheme),
                  // iconButtonTheme: IconButtonThemeData(
                  //     style: IconButton.styleFrom(
                  //         foregroundColor: dark.iconTheme.color)),
                  listTileTheme: dark.listTileTheme.copyWith(
                    iconColor: dark.iconTheme.color,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TakeoutMobileWidget extends StatefulWidget {
  const TakeoutMobileWidget({super.key});

  @override
  TakeoutMobileState createState() => TakeoutMobileState();
}

class TakeoutMobileState extends TakeoutState<TakeoutMobileWidget> {
  @override
  Widget body(AppState state) {
    return Scaffold(
      floatingActionButton: RepaintBoundary(child: FabWidget()),
      body: IndexedStack(index: state.navigationIndex.index, children: pages),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  static const navigationIndices = [
    NavigationIndex.home,
    NavigationIndex.artists,
    NavigationIndex.history,
    NavigationIndex.radio,
    NavigationIndex.player,
  ];

  Widget _bottomNavigation() {
    return Stack(
      children: [
        BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            var index = state.navigationIndex;
            return NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: index == NavigationIndex.home
                      ? const Icon(Icons.home)
                      : const Icon(Icons.home_outlined),
                  label: context.strings.navHome,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.artists
                      ? const Icon(Icons.people_alt)
                      : const Icon(Icons.people_alt_outlined),
                  label: context.strings.navArtists,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.history
                      ? const Icon(Icons.history)
                      : const Icon(Icons.history_outlined),
                  label: context.strings.navHistory,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.radio
                      ? const Icon(Icons.radio)
                      : const Icon(Icons.radio_outlined),
                  label: context.strings.navRadio,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.player
                      ? const Icon(Icons.queue_music)
                      : const Icon(Icons.queue_music_outlined),
                  label: context.strings.navPlayer,
                ),
              ],
              selectedIndex: index.index,
              onDestinationSelected: (index) => onNavTapped(context, index),
            );
          },
        ),
      ],
    );
  }
}
