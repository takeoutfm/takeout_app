import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/history/widget.dart';
import 'package:takeout_mobile/home/home.dart';
import 'package:takeout_mobile/pages/artists.dart';
import 'package:takeout_mobile/pages/login.dart';
import 'package:takeout_mobile/pages/radio.dart';
import 'package:takeout_mobile/player/widget.dart';

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
  };

  NavigatorState? _navigatorState(NavigationIndex index) =>
      _navigators[index]?.currentState;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    pages = [
      navigatorPage(HomeWidget(), key: _navigators[NavigationIndex.home]),
      navigatorPage(ArtistsWidget(), key: _navigators[NavigationIndex.artists]),
      navigatorPage(
        HistoryListWidget(),
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

  bool popToFirst() {
    NavigatorState? navState = _navigatorState(context.app.state.index);
    if (navState != null && navState.canPop()) {
      navState.popUntil((route) => route.isFirst);
      return true;
    }
    return false;
  }

  void onNavTapped(BuildContext context, int index) {
    final currentIndex = context.app.state.navigationIndex;
    print('tapped $index / $currentIndex ${currentIndex.index}');
    if (currentIndex.index == index) {
      if (!popToFirst()) {
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
          child: body(state),
        );
      },
    );
  }

  Widget body(AppState state);
}
