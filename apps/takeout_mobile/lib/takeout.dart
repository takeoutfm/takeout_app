// Copyright 2026 defsub
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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/history/widget.dart';
import 'package:takeout_mobile/home/home.dart';
import 'package:takeout_mobile/pages/login.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/radio.dart';
import 'package:takeout_mobile/pages/search/search.dart';
import 'package:takeout_mobile/player/player.dart';

abstract class TakeoutState<T> extends State
    with AppBlocState, WidgetsBindingObserver {
  static final _navigators = {
    NavigationIndex.home: GlobalKey<NavigatorState>(),
    NavigationIndex.artists: GlobalKey<NavigatorState>(),
    NavigationIndex.history: GlobalKey<NavigatorState>(),
    NavigationIndex.radio: GlobalKey<NavigatorState>(),
    NavigationIndex.player: GlobalKey<NavigatorState>(),
    NavigationIndex.music: GlobalKey<NavigatorState>(),
    NavigationIndex.film: GlobalKey<NavigatorState>(),
    NavigationIndex.tv: GlobalKey<NavigatorState>(),
    NavigationIndex.podcast: GlobalKey<NavigatorState>(),
    NavigationIndex.search: GlobalKey<NavigatorState>(),
  };

  @protected
  NavigatorState? navigatorState(NavigationIndex index) =>
      _navigators[index]?.currentState;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    pages = [
      navigatorPage(HomeWidget(), key: _navigators[NavigationIndex.home]),
      navigatorPage(
        AllArtistsGrid(),
        key: _navigators[NavigationIndex.artists],
      ),
      navigatorPage(
        HistoryWidget(),
        key: _navigators[NavigationIndex.history],
      ),
      navigatorPage(RadioWidget(), key: _navigators[NavigationIndex.radio]),
      navigatorPage(PlayerWidget(), key: _navigators[NavigationIndex.player]),
      navigatorPage(
        MusicMediaWidget(),
        key: _navigators[NavigationIndex.music],
      ),
      navigatorPage(FilmMediaWidget(), key: _navigators[NavigationIndex.film]),
      navigatorPage(TVMediaWidget(), key: _navigators[NavigationIndex.tv]),
      navigatorPage(
        PodcastMediaWidget(),
        key: _navigators[NavigationIndex.podcast],
      ),
      navigatorPage(SearchPage(), key: _navigators[NavigationIndex.search]),
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

  void handleBack() {
    final navState = navigatorState(context.app.state.index);
    if (navState != null) {
      navState.maybePop();
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

  bool popToFirst() {
    NavigatorState? navState = navigatorState(context.app.state.index);
    if (navState != null && navState.canPop()) {
      navState.popUntil((route) => route.isFirst);
      return true;
    }
    return false;
  }

  bool onNavTapped(
    BuildContext context,
    int index, {
    bool selectNextMediaType = true,
  }) {
    final currentIndex = context.app.state.navigationIndex;
    bool popped = false;
    if (currentIndex.index == index) {
      popped = popToFirst();
      if (!popped) {
        if (selectNextMediaType) {
          context.selectedMediaType.next();
        }
      }
    } else {
      context.app.goto(index);
    }
    return popped;
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
            final navState = navigatorState(navIndex);
            if (navState != null) {
              final handled = await navState.maybePop();
              if (!handled && navIndex == NavigationIndex.home) {
                // allow pop and app to exit
                await SystemNavigator.pop();
              }
            }
          },
          child: body(state),
        );
      },
    );
  }

  Widget body(AppState state);
}
