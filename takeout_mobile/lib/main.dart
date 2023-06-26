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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/history/widget.dart';
import 'package:takeout_mobile/player/widget.dart';
import 'package:takeout_lib/context/bloc.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/player/player.dart';

import 'artists.dart';
import 'home.dart';
import 'login.dart';
import 'radio.dart';
import 'search.dart';

void main() async {
  // setup the logger
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.loggerName}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  await TakeoutBloc.initStorage();

  runApp(const TakeoutApp());
}

class TakeoutApp extends StatelessWidget {
  const TakeoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBloc().init(context, child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      final light = ThemeData.light(useMaterial3: true);
      final dark = ThemeData.dark(useMaterial3: true);
      return MaterialApp(
          onGenerateTitle: (context) => context.strings.takeoutTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          home: const _TakeoutWidget(),
          theme: light.copyWith(
              colorScheme: lightDynamic,
              // appBarTheme:
              //     light.appBarTheme.copyWith(iconTheme: light.iconTheme),
              // iconButtonTheme: IconButtonThemeData(
              //     style: IconButton.styleFrom(
              //         foregroundColor: light.iconTheme.color)),
              listTileTheme: light.listTileTheme
                  .copyWith(iconColor: light.iconTheme.color)),
          darkTheme: dark.copyWith(
              colorScheme: darkDynamic,
              // appBarTheme: dark.appBarTheme.copyWith(iconTheme: dark.iconTheme),
              // iconButtonTheme: IconButtonThemeData(
              //     style: IconButton.styleFrom(
              //         foregroundColor: dark.iconTheme.color)),
              listTileTheme: dark.listTileTheme
                  .copyWith(iconColor: dark.iconTheme.color)));
    }));
  }
}

class _TakeoutWidget extends StatefulWidget {
  const _TakeoutWidget();

  @override
  _TakeoutState createState() => _TakeoutState();
}

class _TakeoutState extends State<_TakeoutWidget>
    with AppBlocState, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
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

  // This will auto-pause playback for remote media when streaming is disabled.
  // void _onMediaItem(MediaItem? mediaItem) {
  //   if (audioHandler.playbackState.hasValue &&
  //       audioHandler.playbackState.value == true) {
  //     final streaming = mediaItem?.isRemote() ?? false;
  //     if (streaming && allowStreaming(connectivityStream.value) == false) {
  //       log.finer('mediaItem pause due to loss of wifi');
  //       audioHandler.pause();
  //     }
  //   }
  // }

  // Future<LiveClient> _createLiveClient(Client client) async {
  //   final token = await client.getAccessToken();
  //   final url = await client.getEndpoint();
  //   final uri = Uri.parse(url);
  //   return LiveClient('${uri.host}:${uri.port}', token!);
  // }
  //
  // LiveFollow? _liveFollow;
  // LiveShare? _liveShare;
  //
  // void _onLiveChange(LiveType liveType) async {
  //   _liveFollow?.stop();
  //   _liveFollow = null;
  //   _liveShare?.stop();
  //   _liveShare = null;
  //   if (liveType == LiveType.none) {
  //     return;
  //   }
  //   final client = Client();
  //   final live = await _createLiveClient(client);
  //   if (liveType == LiveType.follow) {
  //     _liveFollow = LiveFollow(live, audioHandler);
  //     _liveFollow!.start();
  //   } else if (settingsLiveType() == LiveType.share) {
  //     _liveShare = LiveShare(live, audioHandler);
  //     _liveShare!.start();
  //   }
  // }
  //
  // void _live() async {
  //   // start with the current value
  //   _onLiveChange(settingsLiveType());
  //   // listen for changes
  //   settingsChangeSubject.listen((setting) {
  //     if (setting == settingLiveMode) {
  //       _onLiveChange(settingsLiveType());
  //     }
  //   });
  // }

  static final _routes = [
    '/home',
    '/artists',
    '/history',
    '/radio',
    '/player',
  ];

  static final _navigatorKeys = {
    NavigationIndex.home: GlobalKey<NavigatorState>(),
    NavigationIndex.artists: GlobalKey<NavigatorState>(),
    NavigationIndex.history: GlobalKey<NavigatorState>(),
    NavigationIndex.radio: GlobalKey<NavigatorState>(),
    NavigationIndex.player: GlobalKey<NavigatorState>(),
  };

  NavigatorState? _navigatorState(NavigationIndex index) =>
      _navigatorKeys[index]?.currentState;

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
    return BlocBuilder<AppCubit, AppState>(builder: (context, state) {
      if (state.authenticated == false) {
        return LoginWidget();
      }
      final builders = _pageBuilders();
      final pages = List.generate(
          _routes.length, (index) => builders[_routes[index]]!(context));
      return WillPopScope(
          onWillPop: () async {
            NavigatorState? navState = _navigatorState(context.app.state.index);
            if (navState != null) {
              final handled = await navState.maybePop();
              if (!handled && context.app.state.index == NavigationIndex.home) {
                // allow pop and app to exit
                return true;
              }
            }
            return false;
          },
          child: Scaffold(
              floatingActionButton: _fab(context),
              body: IndexedStack(
                  index: state.navigationBarIndex, children: pages),
              bottomNavigationBar: _bottomNavigation()));
    });
  }

  Widget _fab(BuildContext context) {
    return BlocBuilder<Player, PlayerState>(builder: (context, state) {
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
      if (state is PlayerPositionState) {
        playing = state.playing;
        progress = state.progress;
        if (state.buffering) {
          progress = null;
        }
      }
      return Stack(alignment: Alignment.center, children: [
        FloatingActionButton(
            onPressed: () =>
                playing ? context.player.pause() : context.player.play(),
            shape: const CircleBorder(),
            child: playing
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow)),
        IgnorePointer(
            child: SizedBox(
                width: 52, // non-mini FAB is 56, progress is 4
                height: 52,
                child: CircularProgressIndicator(value: progress))),
      ]);
    });
  }

  Widget _bottomNavigation() {
    return Stack(children: [
      BlocBuilder<AppCubit, AppState>(builder: (context, state) {
        final index = state.navigationBarIndex;
        return BottomNavigationBar(
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.strings.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_alt),
              label: context.strings.navArtists,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: context.strings.navHistory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.radio),
              label: context.strings.navRadio,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.queue_music),
              label: context.strings.navPlayer,
            ),
          ],
          currentIndex: index,
          onTap: (index) => _onNavTapped(context, index),
        );
      }),
    ]);
  }

  Map<String, WidgetBuilder> _pageBuilders() {
    final builders = {
      '/home': (_) => HomeWidget(
          (ctx) => Navigator.push(
              ctx, MaterialPageRoute<void>(builder: (_) => SearchWidget())),
          key: _navigatorKeys[NavigationIndex.home]),
      '/artists': (_) =>
          ArtistsWidget(key: _navigatorKeys[NavigationIndex.artists]),
      '/history': (_) =>
          HistoryListWidget(key: _navigatorKeys[NavigationIndex.history]),
      '/radio': (_) => RadioWidget(key: _navigatorKeys[NavigationIndex.radio]),
      '/player': (_) =>
          PlayerWidget(key: _navigatorKeys[NavigationIndex.player])
    };
    return builders;
  }
}
