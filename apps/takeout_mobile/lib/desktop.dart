import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/home/media_bar.dart';
import 'package:takeout_mobile/home/menu.dart';
import 'package:takeout_mobile/takeout.dart';

class TakeoutDesktopWidget extends StatefulWidget {
  const TakeoutDesktopWidget({super.key});

  @override
  TakeoutDesktopState createState() => TakeoutDesktopState();
}

class TakeoutDesktopState extends TakeoutState<TakeoutDesktopWidget>
    with AppBlocState, WidgetsBindingObserver {
  bool extended = false;

  void _toggleExtended() {
    setState(() {
      extended = !extended;
    });
  }

  @override
  Widget body(AppState state) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: extended
              ? const Icon(Icons.menu_open_outlined)
              : const Icon(Icons.menu),
          onPressed: () {
            _toggleExtended();
          },
        ),
        title: Text('Takeout'),
        actions: [HomeMenu()],
        // actions: actions(context),
      ),
      body: Row(
        children: [
          _navigationRail(),
          Expanded(
            child: IndexedStack(
              index: state.navigationIndex.index,
              children: pages,
            ),
          ),
        ],
      ),
    );
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
        // popToFirst(); TODO check if needed
        return NavigationRail(
          extended: extended,
          labelType: NavigationRailLabelType.none,
          destinations: [
            NavigationRailDestination(
              icon: index == NavigationIndex.music
                  ? const Icon(Icons.music_note)
                  : const Icon(Icons.music_note_outlined),
              label: Text(context.strings.musicSwitchLabel),
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
              label: Text(context.strings.moviesLabel),
            ),
            NavigationRailDestination(
              icon: index == NavigationIndex.tv
                  ? const Icon(Icons.tv)
                  : const Icon(Icons.tv_outlined),
              label: Text(context.strings.tvEpisodesLabel),
            ),
            NavigationRailDestination(
              icon: index == NavigationIndex.podcast
                  ? const Icon(Icons.podcasts)
                  : const Icon(Icons.podcasts_outlined),
              label: Text(context.strings.podcastsSwitchLabel),
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
            NavigationRailDestination(
              icon: const Icon(Icons.search),
              label: Text(context.strings.searchLabel),
            ),
          ],
          selectedIndex: navigationIndices.indexOf(index),
          onDestinationSelected: (index) {
            final navIndex = navigationIndices[index];
            if (navIndex == context.app.state.index) {
              switch (navIndex) {
                case .music:
                  context.selectedMediaType.nextMusicType();
                case .film:
                  context.selectedMediaType.nextFilmType();
                case .podcast:
                  context.selectedMediaType.nextPodcastType();
                case .tv:
                // TODO
                default:
              }
            } else {
              onNavTapped(context, navIndex.index);
            }
          },
        );
      },
    );
  }
}

class HomeDesktopWidget extends StatelessWidget {
  const HomeDesktopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final indexState = context.watch<IndexCubit>().state;
    final mediaTypeState = context.watch<MediaTypeCubit>().state;
    return EmptyWidget();
  }
}
