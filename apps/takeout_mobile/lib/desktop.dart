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

import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/home/menu.dart';
import 'package:takeout_mobile/player/mini_player.dart';
import 'package:takeout_mobile/takeout.dart';

class TakeoutDesktopWidget extends StatefulWidget {
  const TakeoutDesktopWidget({super.key});

  @override
  TakeoutDesktopState createState() => TakeoutDesktopState();
}

class TakeoutDesktopState extends TakeoutState<TakeoutDesktopWidget>
    with AppBlocState, WidgetsBindingObserver {
  @override
  Widget body(AppState state) {
    return Scaffold(
      appBar: AppBar(
        leading: _searchButton(context),
        title: _NavTitleWidget(),
        actions: [HomeMenu()],
        // actions: actions(context),
      ),
      body: Row(
        children: [
          DpadRegion(
            verticalEdge: DpadEdgeBehavior.leave,
            child: _navigationRail(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: DpadRegion(
                    horizontalEdge: .leave,
                    verticalEdge: .leave,
                    child: Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent &&
                            (event.logicalKey == .arrowLeft ||
                                event.logicalKey == .goBack)) {
                          final before = FocusManager.instance.primaryFocus;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (FocusManager.instance.primaryFocus == before) {
                              final focus = navigationFocusNodes[state.index];
                              focus?.requestFocus();
                            }
                          });

                          // Force a frame to actually happen, since nothing else may trigger
                          // one — this is what the debug overlay was accidentally doing for us.
                          SchedulerBinding.instance.scheduleFrame();
                          return KeyEventResult.ignored;
                        } else if (event is KeyDownEvent &&
                            event.logicalKey == .escape) {
                          handleBack();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: IndexedStack(
                        index: state.navigationIndex.index,
                        children: pages,
                      ),
                    ),
                  ),
                ),
                if (_showMiniPlayer(context)) ...[
                  SizedBox(height: 5),
                  RepaintBoundary(
                    child: SizedBox(
                      height: MiniPlayer.height,
                      child: MiniPlayer(),
                    ),
                  ),
                ],
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _showMiniPlayer(BuildContext context) {
    switch (context.app.state.navigationIndex) {
      case .music || .radio || .podcast || .artists || .history:
        return true;
      default:
        return false;
    }
  }

  static const navigationIndices = [
    NavigationIndex.music,
    NavigationIndex.artists,
    NavigationIndex.radio,
    NavigationIndex.film,
    NavigationIndex.tv,
    NavigationIndex.podcast,
    NavigationIndex.history,
    NavigationIndex.player,
    // NavigationIndex.search,
  ];

  static final navigationFocusNodes = <NavigationIndex, FocusNode>{
    NavigationIndex.music: FocusNode(),
    NavigationIndex.artists: FocusNode(),
    NavigationIndex.radio: FocusNode(),
    NavigationIndex.film: FocusNode(),
    NavigationIndex.tv: FocusNode(),
    NavigationIndex.podcast: FocusNode(),
    NavigationIndex.history: FocusNode(),
    NavigationIndex.player: FocusNode(),
    NavigationIndex.search: FocusNode(),
  };

  static final navigationIcons = <NavigationIndex, List<IconData>>{
    NavigationIndex.music: [Icons.speaker, Icons.speaker_outlined],
    NavigationIndex.artists: [Icons.people, Icons.people_outline],
    NavigationIndex.radio: [Icons.radio, Icons.radio_outlined],
    NavigationIndex.film: [Icons.movie, Icons.movie_outlined],
    NavigationIndex.tv: [Icons.live_tv, Icons.live_tv],
    NavigationIndex.podcast: [Icons.podcasts, Icons.podcasts_outlined],
    NavigationIndex.history: [Icons.history, Icons.history_outlined],
    NavigationIndex.player: [Icons.playlist_play, Icons.playlist_play_outlined],
    // NavigationIndex.search: [Icons.search, Icons.search],
  };

  NavigationRailDestination destination(
    NavigationIndex selectedIndex,
    NavigationIndex index,
  ) {
    final icons = navigationIcons[index] ?? [Icons.error, Icons.error_outline];
    final icon = selectedIndex == index ? icons[0] : icons[1];
    final label = switch (index) {
      .music => context.strings.navMusic,
      .artists => context.strings.navArtists,
      .radio => context.strings.navRadio,
      .film => context.strings.navMovies,
      .tv => context.strings.navTVShows,
      .podcast => context.strings.navPodcasts,
      .history => context.strings.navHistory,
      .player => context.strings.navPlayer,
      .search => context.strings.navSearch, // unused
      .home => context.strings.navHome, // unused
    };
    return NavigationRailDestination(
      icon: Focus(
        focusNode: navigationFocusNodes[index],
        child: Icon(icon),
      ),
      label: Text(label),
    );
  }

  Widget _navigationRail() {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final index = state.navigationIndex;
        final destinations = [
          destination(index, NavigationIndex.music),
          destination(index, NavigationIndex.artists),
          destination(index, NavigationIndex.radio),
          destination(index, NavigationIndex.film),
          destination(index, NavigationIndex.tv),
          destination(index, NavigationIndex.podcast),
          destination(index, NavigationIndex.history),
          destination(index, NavigationIndex.player),
          // destination(index, NavigationIndex.search),
        ];
        var selectedIndex = navigationIndices.indexOf(index);
        if (selectedIndex < 0 || selectedIndex >= destinations.length) {
          // handle screen rotation or resizing
          selectedIndex = 0;
        }
        return NavigationRail(
          labelType: NavigationRailLabelType.none,
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: (destIndex) {
            final navIndex = navigationIndices[destIndex];
            final popped = onNavTapped(
              context,
              navIndex.index,
              selectNextMediaType: false,
            );
            if (!popped) {
              // no pop so update selection or next type
              switch (navIndex) {
                case .music:
                  if (index == navIndex) {
                    context.selectedMediaType.nextMusicType();
                  } else {
                    context.selectedMediaType.select(.music);
                  }
                case .film:
                  if (index == navIndex) {
                    context.selectedMediaType.nextFilmType();
                  } else {
                    context.selectedMediaType.select(.film);
                  }
                case .podcast:
                  if (index == navIndex) {
                    context.selectedMediaType.nextPodcastType();
                  } else {
                    context.selectedMediaType.select(.podcast);
                  }
                case .tv:
                  context.selectedMediaType.select(.tv);
                default:
                // nada
              }
            }
          },
        );
      },
    );
  }

  Widget _searchButton(BuildContext context) {
    final onSearch = () {
      onNavTapped(
        context,
        NavigationIndex.search.index,
        selectNextMediaType: false,
      );
    };
    return DpadFocusable(
      focusNode: navigationFocusNodes[NavigationIndex.search],
      onSelect: onSearch,
      child: IconButton(icon: const Icon(Icons.search), onPressed: onSearch),
    );
  }
}

class _NavTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final title = switch (state.navigationIndex) {
      .music => context.strings.navMusic,
      .artists => context.strings.navArtists,
      .radio => context.strings.navRadio,
      .film => context.strings.navMovies,
      .tv => context.strings.navTVShows,
      .podcast => context.strings.navPodcasts,
      .history => context.strings.navHistory,
      .player => context.strings.navPlayer,
      .search => context.strings.navSearch,
      _ => 'Takeout',
    };
    return Text(title);
  }
}
