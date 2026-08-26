import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/home/menu.dart';
import 'package:takeout_mobile/pages/search/search_results.dart';
import 'package:takeout_mobile/player/mini_player.dart';
import 'package:takeout_mobile/takeout.dart';

class TakeoutDesktopWidget extends StatefulWidget {
  const TakeoutDesktopWidget({super.key});

  @override
  TakeoutDesktopState createState() => TakeoutDesktopState();
}

class TakeoutDesktopState extends TakeoutState<TakeoutDesktopWidget>
    with AppBlocState, WidgetsBindingObserver {
  bool extended = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleExtended() {
    setState(() {
      extended = !extended;
    });
  }

  @override
  Widget body(AppState state) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78, // default is 56
        leading: IconButton(
          icon: extended
              ? const Icon(Icons.menu_open_outlined)
              : const Icon(Icons.menu),
          onPressed: () {
            _toggleExtended();
          },
        ),
        title: _searchBar(),
        actions: [HomeMenu()],
        // actions: actions(context),
      ),
      body: Row(
        children: [
          DpadRegion(
            verticalEdge: DpadEdgeBehavior.stop,
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
                            event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                          final before = FocusManager.instance.primaryFocus;
                          // Let dpad attempt its own handling first (this
                          // callback fires on the bubble/ancestor pass, after
                          // descendants have already had a chance). Check on
                          // the next frame whether focus actually changed; if
                          // not, dpad found no exit target, so redirect to the
                          // sidebar ourselves.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (FocusManager.instance.primaryFocus == before) {
                              final focus = navigationFocusNodes[state.index];
                              focus?.requestFocus();
                              // TODO need to help move focus from icon
                              // to outer nav rail dest
                              // context.app.goto(state.index.index);
                            }
                          });
                        }
                        // Always ignore so dpad still gets/keeps normal handling.
                        return KeyEventResult.ignored;
                      },
                      child: IndexedStack(
                        index: state.navigationIndex.index,
                        children: pages,
                      ),
                    ),
                  ),
                ),
                if (context.app.state.navigationIndex != .player) ...[
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

  Widget _searchBar() {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          _onSearch(_controller.text);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SearchBar(
        controller: _controller,
        constraints: const BoxConstraints(
          minHeight: 40,
          maxWidth: double.infinity,
        ),
        hintText: 'Takeout Search',
        leading: const Icon(Icons.search),
        trailing: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                // _onChanged('');
              },
            ),
        ],
        // onChanged: _onChanged,
        onChanged: (v) => debugPrint('onChanged: $v'),
        onSubmitted: (query) => _onSearch(query),
      ),
    );
  }

  void _onSearch(String query) {
    query = query.trim();
    if (query.isEmpty) {
      return;
    }
    navigatorState(
      context.app.state.index,
    )?.push(MaterialPageRoute<void>(builder: (_) => SearchResults(query)));
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
      .home => context.strings.navHome, // unused
    };
    return NavigationRailDestination(
      icon: Focus(
        focusNode: navigationFocusNodes[index],
        // onFocusChange: (focused) {
        //   if (focused) {
        //     print('focusChange $index');
        //     lastSidebarFocus = navigationFocusNodes[index];
        //   }
        // },
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
        ];
        var selectedIndex = navigationIndices.indexOf(index);
        if (selectedIndex < 0 || selectedIndex >= destinations.length) {
          // handle screen rotation or resizing
          selectedIndex = 0;
        }
        return NavigationRail(
          extended: extended,
          labelType: NavigationRailLabelType.none,
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            final navIndex = navigationIndices[index];
            final popped = onNavTapped(
              context,
              navIndex.index,
              selectNextMediaType: false,
            );
            if (!popped) {
              // no pop so update selection or next type
              switch (navIndex) {
                case .music:
                  if (context.selectedMediaType.state.isMusic()) {
                    context.selectedMediaType.nextMusicType();
                  } else {
                    context.selectedMediaType.select(.music);
                  }
                case .film:
                  if (context.selectedMediaType.state.isFilm()) {
                    context.selectedMediaType.nextFilmType();
                  } else {
                    context.selectedMediaType.select(.film);
                  }
                case .podcast:
                  if (context.selectedMediaType.state.isPodcast()) {
                    context.selectedMediaType.nextPodcastType();
                  } else {
                    context.selectedMediaType.select(.podcast);
                  }
                case .tv:
                  context.selectedMediaType.select(.tv);
                default:
              }
              // print(context.selectedMediaType.state.toJson());
            }
          },
        );
      },
    );
  }
}
