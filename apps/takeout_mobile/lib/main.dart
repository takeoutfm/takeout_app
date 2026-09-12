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

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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

  final androidTV = await isAndroidTV();
  final dpad = await checkDpadNavigation();

  runApp(TakeoutApp(preferDpadNavigation: dpad, androidTV: androidTV));
}

final _desktopKey = GlobalKey<TakeoutState<TakeoutDesktopWidget>>();
final _mobileKey = GlobalKey<TakeoutState<TakeoutMobileState>>();

/// returns true if primary navigation is using dpad/keyboard
Future<bool> checkDpadNavigation() async {
  if (Platform.isAndroid) {
    // check for Android with Android TV
    return await isAndroidTV();
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    // check for Desktop
    return true;
  }
  return false;
}

Future<bool> isAndroidTV() async {
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.systemFeatures.contains('android.software.leanback');
  }
  return false;
}

class TakeoutApp extends StatelessWidget {
  final bool preferDpadNavigation;
  final bool androidTV;

  const TakeoutApp({
    this.preferDpadNavigation = false,
    this.androidTV = false,
    super.key,
  });

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
              if (orientation == .portrait) {
                context.app.home();
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
                  // debugOverlay: true,
                  enabled: preferDpadNavigation,
                  theme: DpadThemeData(
                    effects: [
                      DpadScaleEffect(scale: 1.06),
                      DpadBorderEffect(),
                      DpadGlowEffect(),
                    ],
                    scrollPadding: 48,
                  ),
                  // onBack: () {
                  //   // final handled = orientation == .landscape
                  //   //     ? (_desktopKey.currentState?.handleBack() ?? false)
                  //   //     : (_mobileKey.currentState?.handleBack() ?? false);
                  //   // return handled;
                  //   return false;
                  // },
                  keySet: DpadKeySet().copyWith(back: []),
                  onBack: null,
                  shortcuts: {
                    LogicalKeyboardKey.play: () => context.player.toggle(),
                    LogicalKeyboardKey.pause: () => context.player.toggle(),
                  },
                ),
                home: home,
                themeMode: androidTV ? .dark : .system,
                theme: light.copyWith(
                  colorScheme: lightDynamic,
                  listTileTheme: light.listTileTheme.copyWith(
                    iconColor: light.iconTheme.color,
                  ),
                ),
                darkTheme: dark.copyWith(
                  colorScheme: darkDynamic,
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

  // static const navigationIndices = [
  //   NavigationIndex.home,
  //   NavigationIndex.artists,
  //   NavigationIndex.history,
  //   NavigationIndex.radio,
  //   NavigationIndex.player,
  // ];

  Widget _bottomNavigation() {
    return Stack(
      children: [
        BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            var index = state.navigationIndex;
            return NavigationBar(
              labelBehavior: .alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: index == .home
                      ? const Icon(Icons.home)
                      : const Icon(Icons.home_outlined),
                  label: context.strings.navHome,
                ),
                NavigationDestination(
                  icon: index == .artists
                      ? const Icon(Icons.people_alt)
                      : const Icon(Icons.people_alt_outlined),
                  label: context.strings.navArtists,
                ),
                NavigationDestination(
                  icon: index == .history
                      ? const Icon(Icons.history)
                      : const Icon(Icons.history_outlined),
                  label: context.strings.navHistory,
                ),
                NavigationDestination(
                  icon: index == .radio
                      ? const Icon(Icons.radio)
                      : const Icon(Icons.radio_outlined),
                  label: context.strings.navRadio,
                ),
                NavigationDestination(
                  icon: index == .player
                      ? const Icon(Icons.queue_music)
                      : const Icon(Icons.queue_music_outlined),
                  label: context.strings.navPlayer,
                ),
              ],
              selectedIndex: index == .search
                  ? NavigationIndex.home.index
                  : index.index,
              onDestinationSelected: (index) => onNavTapped(context, index),
            );
          },
        ),
      ],
    );
  }
}
