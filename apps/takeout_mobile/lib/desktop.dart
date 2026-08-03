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
    return Shortcuts(
      shortcuts: _shortcutKeys(),
      child: Actions(
        actions: _shortcutActions(context),
        child: Scaffold(
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
              _navigationRail(),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: state.navigationIndex.index,
                        children: pages,
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
        ),
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

  Widget _navigationRail() {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final index = state.navigationIndex;
        final destinations = [
          NavigationRailDestination(
            icon: index == NavigationIndex.music
                ? const Icon(Icons.speaker)
                : const Icon(Icons.speaker_outlined),
            label: Text(context.strings.navMusic),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.artists
                ? const Icon(Icons.people_alt)
                : const Icon(Icons.people_alt_outlined),
            label: Text(context.strings.navArtists),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.radio
                ? const Icon(Icons.radio)
                : const Icon(Icons.radio_outlined),
            label: Text(context.strings.navRadio),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.film
                ? const Icon(Icons.movie)
                : const Icon(Icons.movie_outlined),
            label: Text(context.strings.navMovies),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.tv
                ? const Icon(Icons.tv)
                : const Icon(Icons.tv_outlined),
            label: Text(context.strings.navTVShows),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.podcast
                ? const Icon(Icons.podcasts)
                : const Icon(Icons.podcasts_outlined),
            label: Text(context.strings.navPodcasts),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.history
                ? const Icon(Icons.history)
                : const Icon(Icons.history_outlined),
            label: Text(context.strings.navHistory),
          ),
          NavigationRailDestination(
            icon: index == NavigationIndex.player
                ? const Icon(Icons.queue_music)
                : const Icon(Icons.queue_music_outlined),
            label: Text(context.strings.navPlayer),
          ),
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

// class HomeDesktopWidget extends StatelessWidget {
//   const HomeDesktopWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final indexState = context.watch<IndexCubit>().state;
//     final mediaTypeState = context.watch<MediaTypeCubit>().state;
//     return EmptyWidget();
//   }
// }

class BackIntent extends Intent {}

class PlayPauseIntent extends Intent {}

class NextFieldIntent extends Intent {}

// class UpIntent extends Intent {}
//
// class DownIntent extends Intent {}
//
// class LeftIntent extends Intent {}
//
// class RightIntent extends Intent {}

class PlayIntent extends Intent {}

class PauseIntent extends Intent {}

class TrackNextIntent extends Intent {}

class TrackPreviousIntent extends Intent {}

Map<ShortcutActivator, Intent> _shortcutKeys() {
  return {
    LogicalKeySet(LogicalKeyboardKey.escape): BackIntent(),
    LogicalKeySet(LogicalKeyboardKey.space): PlayPauseIntent(),
    LogicalKeySet(LogicalKeyboardKey.tab): NextFieldIntent(),
    // LogicalKeySet(LogicalKeyboardKey.arrowUp): UpIntent(),
    // LogicalKeySet(LogicalKeyboardKey.arrowDown): DownIntent(),
    // LogicalKeySet(LogicalKeyboardKey.arrowLeft): LeftIntent(),
    // LogicalKeySet(LogicalKeyboardKey.arrowRight): RightIntent(),
    LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
    LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
    LogicalKeySet(LogicalKeyboardKey.mediaPlayPause): PlayPauseIntent(),
    LogicalKeySet(LogicalKeyboardKey.mediaPlay): PlayIntent(),
    LogicalKeySet(LogicalKeyboardKey.mediaPause): PlayIntent(),
    LogicalKeySet(LogicalKeyboardKey.mediaTrackNext): TrackNextIntent(),
    LogicalKeySet(LogicalKeyboardKey.mediaTrackPrevious): TrackPreviousIntent(),

    // LogicalKeyboardKey.mediaFastForward
    // LogicalKeyboardKey.mediaRewind
  };
}

Map<Type, Action<Intent>> _shortcutActions(BuildContext context) {
  return {
    BackIntent: CallbackAction<BackIntent>(
      onInvoke: (intent) {
        Navigator.of(context).maybePop();
        return null;
      },
    ),
    PlayPauseIntent: CallbackAction<PlayPauseIntent>(
      onInvoke: (intent) {
        context.player.toggle();
        return null;
      },
    ),
    NextFieldIntent: CallbackAction<NextFieldIntent>(
      onInvoke: (intent) {
        FocusScope.of(context).nextFocus();
        return null;
      },
    ),
    PlayIntent: CallbackAction<PlayIntent>(
      onInvoke: (intent) {
        context.player.play();
        return null;
      },
    ),
    PauseIntent: CallbackAction<PauseIntent>(
      onInvoke: (intent) {
        context.player.pause();
        return null;
      },
    ),
    TrackNextIntent: CallbackAction<TrackNextIntent>(
      onInvoke: (intent) {
        context.player.skipToNext();
        return null;
      },
    ),
    TrackPreviousIntent: CallbackAction<TrackPreviousIntent>(
      onInvoke: (intent) {
        context.player.skipToPrevious();
        return null;
      },
    ),
  };
}
