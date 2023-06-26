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

// This file is heavily based on the audio_service example app located here:
// https://github.com/ryanheise/audio_service

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/tiles.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/scaffold.dart';
import 'package:takeout_lib/player/seekbar.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final builder = (BuildContext context) => PlayerScaffold(
        body: (backgroundColor) => CustomScrollView(slivers: [
              SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: MediaQuery.of(context).size.height / 3,
                  actions: const [],
                  backgroundColor: backgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      // StretchMode.zoomBackground,
                      StretchMode.fadeTitle
                    ],
                    background: Container(
                        padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
                        child: playerImage(context)),
                    // background: Stack(fit: StackFit.expand, children: [
                    //   playerImage(context),
                    // ]),
                  )),
              SliverToBoxAdapter(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(children: [
                        playerTitle(context),
                        playerArtist(context),
                        playerControls(context),
                        playerSeekBar(context),
                      ]))),
              SliverToBoxAdapter(child: playerQueue(context)),
            ]));
    return Navigator(
        key: key,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: builder, settings: settings);
        });
  }

  Widget playerImage(BuildContext context) {
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) =>
            state is PlayerLoad || state is PlayerIndexChange,
        builder: (context, state) {
          if (state is PlayerLoad || state is PlayerIndexChange) {
            final image = state.currentTrack?.image;
            return image != null
                ? playerCover(context, image)
                : state.spiff.isEmpty
                    ? const Icon(Icons.play_arrow, size: 128)
                    : const Icon(Icons.image_outlined, size: 128);
          }
          return const EmptyWidget();
        });
  }

  Widget playerTitle(BuildContext context) {
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) =>
            state is PlayerLoad ||
            state is PlayerIndexChange ||
            state is PlayerTrackChange,
        builder: (context, state) {
          if (state is PlayerLoad ||
              state is PlayerIndexChange ||
              state is PlayerTrackChange) {
            final currentTrack = state.currentTrack;
            if (currentTrack == null) {
              return const EmptyWidget();
            }
            return GestureDetector(
                onTap: () => _onArtist(context, currentTrack.creator),
                child: Text(currentTrack.title,
                    style: Theme.of(context).textTheme.headlineSmall));
          }
          return const EmptyWidget();
        });
  }

  Widget playerArtist(BuildContext context) {
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) =>
            state is PlayerLoad || state is PlayerIndexChange,
        builder: (context, state) {
          if (state is PlayerLoad || state is PlayerIndexChange) {
            final currentTrack = state.currentTrack;
            if (currentTrack == null) {
              return const EmptyWidget();
            }
            return Text(currentTrack.creator,
                style: Theme.of(context).textTheme.titleMedium!);
          }
          return const EmptyWidget();
        });
  }

  Widget playerControls(BuildContext context) {
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state is PlayerPlay || state is PlayerPause,
        builder: (context, state) {
          if (state.spiff.isEmpty) {
            return const EmptyWidget();
          }
          if (state is PlayerPlay || state is PlayerPause) {
            return _controlButtons(context, state as PlayerPositionState);
          }
          return const EmptyWidget();
        });
  }

  Widget playerSeekBar(BuildContext context) {
    final player = context.player;
    return BlocBuilder<Player, PlayerState>(
        bloc: player,
        buildWhen: (_, state) =>
            state is PlayerIndexChange || state is PlayerPositionState,
        builder: (context, state) {
          if (state.spiff.isEmpty || state.spiff.isStream()) {
            // no controls needed for streams
            return const EmptyWidget();
          }
          if (state is PlayerIndexChange) {
            return _seekBar(player, Duration.zero, Duration.zero);
          } else if (state is PlayerPositionState) {
            return _seekBar(player, state.duration, state.position);
          }
          return const EmptyWidget();
        });
  }

  Widget playerQueue(BuildContext context) {
    final player = context.player;
    return BlocBuilder<Player, PlayerState>(
        bloc: player,
        buildWhen: (_, state) =>
            state is PlayerLoad || state is PlayerIndexChange,
        builder: (context, state) {
          if (state.spiff.isStream() || state.spiff.length == 1) {
            // hide track list
            return const EmptyWidget();
          }
          if (state is PlayerLoad || state is PlayerIndexChange) {
            return _trackList(context, player, state);
          } else if (state is PlayerIndexChange) {
            return _trackList(context, player, state);
          }
          return const EmptyWidget();
        });
  }

  Widget _seekBar(Player player, Duration duration, Duration position) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: SeekBar(
            duration: duration,
            position: position,
            onChangeEnd: (newPosition) => player.seek(newPosition)));
  }

  Widget _controlButtons(BuildContext context, PlayerPositionState state) {
    final player = context.player;
    final isPodcast = state.spiff.isPodcast();
    final isStream = state.spiff.isStream();
    final playing = state.playing;
    final buffering = state.buffering;
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isStream)
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed:
                    state.hasPrevious ? () => player.skipToPrevious() : null,
              ),
            if (isPodcast)
              IconButton(
                icon: const Icon(Icons.replay_10_outlined),
                iconSize: 36,
                onPressed: () => player.skipBackward(),
              ),
            if (buffering)
              // CircularProgressIndicator is 64 by default
              // 22 padding keeps the screen in-place
              Container(
                  padding: const EdgeInsets.all(22.0),
                  child: const CircularProgressIndicator())
            else if (playing)
              IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: () => player.pause(),
              )
            else
              IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: () => player.play(),
              ),
            // stopButton(),
            if (isPodcast)
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.forward_30_outlined),
                onPressed: () => player.skipForward(),
              ),
            if (!isStream)
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: state.hasNext ? () => player.skipToNext() : null,
              ),
          ],
        ));
  }

  void _onArtist(BuildContext context, String artist) {
    context.showArtist(artist);
  }

  Widget _trackList(BuildContext context, Player player, PlayerState state) {
    final tracks = state.spiff.playlist.tracks;
    final sameArtwork = tracks.every((t) => t.image == tracks.first.image);
    return Column(children: [
      ...List.generate(
          tracks.length,
          (index) => CoverTrackListTile.mediaTrack(context, tracks[index],
              showCover: !sameArtwork,
              trailing: _cachedIcon(),
              selected: index == state.currentIndex,
              // TODO
              onTap: () => player.playIndex(index),
              onLongPress: () {
                _onArtist(context, tracks[index].creator);
              }))
    ]);
  }

  Widget? _cachedIcon() {
    // TODO
    return null;
  }
}
