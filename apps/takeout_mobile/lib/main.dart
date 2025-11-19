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
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/log/basic_printer.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/history/widget.dart';
import 'package:takeout_mobile/home.dart';
import 'package:takeout_mobile/l10n/app_localizations.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/artists.dart';
import 'package:takeout_mobile/pages/login.dart';
import 'package:takeout_mobile/pages/radio.dart';
import 'package:takeout_mobile/pages/search.dart';
import 'package:takeout_mobile/player/widget.dart';

void main() async {
  // setup the logger
  Logger.level = Level.debug;
  Logger.defaultFilter = () => ProductionFilter();
  Logger.defaultPrinter = () => BasicPrinter();

  WidgetsFlutterBinding.ensureInitialized();

  await TakeoutBloc.initStorage();

  runApp(const TakeoutApp());
}

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
          return MaterialApp(
            key: globalAppKey,
            onGenerateTitle: (context) => context.strings.takeoutTitle,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', '')],
            home: const _TakeoutWidget(),
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
      ),
    );
  }
}

class _TakeoutWidget extends StatefulWidget {
  const _TakeoutWidget();

  @override
  _TakeoutState createState() => _TakeoutState();
}

class _TakeoutState extends State<_TakeoutWidget>
    with AppBlocState, WidgetsBindingObserver {
  static final _navigators = {
    NavigationIndex.home: GlobalKey<NavigatorState>(),
    NavigationIndex.artists: GlobalKey<NavigatorState>(),
    NavigationIndex.history: GlobalKey<NavigatorState>(),
    NavigationIndex.radio: GlobalKey<NavigatorState>(),
    NavigationIndex.player: GlobalKey<NavigatorState>(),
  };

  NavigatorState? _navigatorState(NavigationIndex index) =>
      _navigators[index]?.currentState;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    pages = [
      navigatorPage(
        HomeWidget(
          (context) => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => SearchWidget()),
          ),
        ),
        key: _navigators[NavigationIndex.home],
      ),
      navigatorPage(ArtistsWidget(), key: _navigators[NavigationIndex.artists]),
      navigatorPage(
        HistoryListWidget(),
        key: _navigators[NavigationIndex.history],
      ),
      navigatorPage(RadioWidget(), key: _navigators[NavigationIndex.radio]),
      navigatorPage(PlayerWidget(), key: _navigators[NavigationIndex.player]),
    ];

    WidgetsBinding.instance.addObserver(this);
    appInitState(context);
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

  Widget navigatorPage(Widget page, {Key? key}) {
    return Navigator(
      key: key,
      observers: [heroController()],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }

  void _onNavTapped(BuildContext context, int index) {
    final currentIndex = context.app.state.navigationBarIndex;
    if (currentIndex == index) {
      NavigatorState? navState = _navigatorState(context.app.state.index);
      if (navState != null && navState.canPop()) {
        navState.popUntil((route) => route.isFirst);
      } else {
        context.selectedMediaType.next();
      }
    } else {
      context.app.goto(index);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        if (state.authenticated == false) {
          return LoginWidget();
        }
        final navIndex = context.app.state.index;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) {
              return;
            }
            NavigatorState? navState = _navigatorState(navIndex);
            if (navState != null) {
              final handled = await navState.maybePop();
              if (!handled && navIndex == NavigationIndex.home) {
                // allow pop and app to exit
                await SystemNavigator.pop();
              }
            }
          },
          child: Scaffold(
            floatingActionButton: _fab(context),
            body: IndexedStack(
              index: state.navigationBarIndex,
              children: pages,
            ),
            bottomNavigationBar: _bottomNavigation(),
          ),
        );
      },
    );
  }

  Widget _fab(BuildContext context) {
    return BlocBuilder<Player, PlayerEvent>(
      builder: (context, state) {
        bool playing = false;
        double? progress;

        if (context.app.state.index == NavigationIndex.player) {
          // hide fab on player page
          return const EmptyWidget();
        }
        if (state is PlayerInit ||
            state is PlayerReady ||
            state is PlayerLoad ||
            state is PlayerStop) {
          // hide fab
          return const EmptyWidget();
        }
        if (state is PlayerPositionEvent) {
          playing = state.playing;
          progress = state.progress;
          if (state.buffering) {
            progress = null;
          }
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton(
              onPressed: () =>
                  playing ? context.player.pause() : context.player.play(),
              shape: const CircleBorder(),
              child: playing
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
            ),
            IgnorePointer(
              child: SizedBox(
                width: 52, // non-mini FAB is 56, progress is 4
                height: 52,
                child: CircularProgressIndicator(value: progress),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bottomNavigation() {
    return Stack(
      children: [
        BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final index = state.navigationBarIndex;
            return NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: index == NavigationIndex.home.index
                      ? const Icon(Icons.home)
                      : const Icon(Icons.home_outlined),
                  label: context.strings.navHome,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.artists.index
                      ? const Icon(Icons.people_alt)
                      : const Icon(Icons.people_alt_outlined),
                  label: context.strings.navArtists,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.history.index
                      ? const Icon(Icons.history)
                      : const Icon(Icons.history_outlined),
                  label: context.strings.navHistory,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.radio.index
                      ? const Icon(Icons.radio)
                      : const Icon(Icons.radio_outlined),
                  label: context.strings.navRadio,
                ),
                NavigationDestination(
                  icon: index == NavigationIndex.player.index
                      ? const Icon(Icons.queue_music)
                      : const Icon(Icons.queue_music_outlined),
                  label: context.strings.navPlayer,
                ),
              ],
              selectedIndex: index,
              onDestinationSelected: (index) => _onNavTapped(context, index),
            );
          },
        ),
      ],
    );
  }
}
