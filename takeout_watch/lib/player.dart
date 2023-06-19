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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/queue.dart';

import 'button.dart';

void showPlayer(BuildContext context) {
  // Scaffold.of(context).showBottomSheet<void>((context) {
  //   return const PlayerPage();
  // });
  Navigator.push(
      context, CupertinoPageRoute<void>(builder: (_) => const PlayerPage()));
}

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final constraints = BoxConstraints(maxWidth: media.size.width - 72);
    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
          Center(child: playerImage(context)),
          Positioned.fill(child: playerProgress(context)),
          Positioned.fill(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlayerTitle(
                            boxConstraints: constraints,
                            style: Theme
                                .of(context)
                                .listTileTheme
                                .titleTextStyle),
                        PlayerArtist(
                            boxConstraints: constraints,
                            style: Theme
                                .of(context)
                                .listTileTheme
                                .subtitleTextStyle),
                        const SizedBox(height: 24),
                        playerControls(context),
                      ]))),
          const Align(alignment: Alignment.bottomCenter, child: PlayerQueue())
        ]));
  }

  Widget playerImage(BuildContext context) {
    String? image;
    final media = MediaQuery.of(context);
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state.currentTrack?.image != image,
        builder: (context, state) {
          final width = state.spiff.isStream()
              ? media.size.width // no progress
              : media.size.width - 26; // room for progress lineWidth: 13
          if (state.currentTrack?.image != image) {
            image = state.currentTrack?.image;
            final cover = image;
            if (cover != null) {
              return GridTile(
                  child: circleCover(
                    context,
                    cover,
                    radius: width / 2,
                    height: width,
                    color: Colors.black45,
                    blendMode: BlendMode.darken,
                  ) ??
                      const EmptyWidget());
            }
          }
          return const EmptyWidget();
        });
  }

  Widget playerProgress(BuildContext context) {
    final media = MediaQuery.of(context);
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state is PlayerPositionChange,
        builder: (context, state) {
          if (state is PlayerPositionChange) {
            return state.spiff.isStream() // no radio stream progress
                ? const EmptyWidget()
                : CircularPercentIndicator(
              radius: media.size.width / 2,
              lineWidth: 13.0,
              animation: true,
              animateFromLastPercent: true,
              percent: state.progress,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.blueAccent,
              backgroundColor: Colors.grey.shade800,
            );
          }
          return const EmptyWidget();
        });
  }

  Widget playerControls(BuildContext context) {
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state is PlayerProcessingState,
        builder: (context, state) {
          if (state is PlayerProcessingState) {
            return _controlButtons(context, state);
          }
          return const EmptyWidget();
        });
  }

  Widget _controlButtons(BuildContext context, PlayerProcessingState state) {
    final player = context.player;
    final isPodcast = state.spiff.isPodcast();
    final isStream = state.spiff.isStream();
    final playing = state.playing;
    final buffering = state.buffering;
    const iconSize = 18.0;
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isStream && !isPodcast)
              CircleButton(
                icon: const Icon(Icons.skip_previous, size: iconSize),
                onPressed:
                state.hasPrevious ? () => player.skipToPrevious() : null,
              ),
            if (isPodcast)
              CircleButton(
                icon: const Icon(Icons.replay_10_outlined, size: iconSize),
                onPressed: () => player.skipBackward(),
              ),
            if (buffering)
              const CircularProgressIndicator()
            else
              if (playing)
                CircleButton(
                  icon: const Icon(Icons.pause, size: 24),
                  onPressed: () => player.pause(),
                )
              else
                CircleButton(
                  icon: const Icon(Icons.play_arrow, size: 24),
                  onPressed: () => player.play(),
                ),
            if (isPodcast)
              CircleButton(
                icon: const Icon(Icons.forward_30_outlined, size: iconSize),
                onPressed: () => player.skipForward(),
              ),
            if (!isStream && !isPodcast)
              CircleButton(
                icon: const Icon(Icons.skip_next, size: iconSize),
                onPressed: state.hasNext ? () => player.skipToNext() : null,
              ),
          ],
        ));
  }
}

class AmbientPlayer extends StatelessWidget {
  const AmbientPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => const PlayerPage()));
    String? title, artist;
    buildWhen(PlayerState state) =>
        state.currentTrack?.title != title ||
            state.currentTrack?.creator != artist;
    return Scaffold(
        body: BlocBuilder<Player, PlayerState>(
            buildWhen: (_, state) => buildWhen(state),
            builder: (context, state) {
              if (buildWhen(state)) {
                return Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                            title: Center(child: Text(title ?? '')),
                            subtitle: Center(child: Text(artist ?? ''))),
                      ],
                    ));
              }
              return const EmptyWidget();
            }));
  }
}

class PlayerArtist extends StatelessWidget {
  final BoxConstraints? boxConstraints;
  final TextStyle? style;

  const PlayerArtist({super.key, this.boxConstraints, this.style});

  @override
  Widget build(BuildContext context) {
    String? artist;
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state.currentTrack?.creator != artist,
        builder: (context, state) {
          // if (state.currentTrack?.creator != artist) {
          final currentTrack = state.currentTrack;
          if (currentTrack == null) {
            return const EmptyWidget();
          }
          artist = currentTrack.creator;
          final child = Text(currentTrack.creator, style: style);
          final constraints = boxConstraints;
          return constraints != null
              ? ConstrainedBox(constraints: constraints, child: child)
              : child;
          // }
          // return const EmptyWidget();
        });
  }
}

class PlayerTitle extends StatelessWidget {
  final BoxConstraints? boxConstraints;
  final TextStyle? style;

  const PlayerTitle({super.key, this.boxConstraints, this.style});

  @override
  Widget build(BuildContext context) {
    String? title;
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state.currentTrack?.title != title,
        builder: (context, state) {
          // if (state.currentTrack?.title != title) {
          final currentTrack = state.currentTrack;
          if (currentTrack == null) {
            return const EmptyWidget();
          }
          title = currentTrack.title;
          final child = Text(currentTrack.title, style: style);
          final constraints = boxConstraints;
          return constraints != null
              ? ConstrainedBox(constraints: constraints, child: child)
              : child;
          // }
          // return const EmptyWidget();
        });
  }
}

class PlayerImage extends StatelessWidget {
  const PlayerImage({super.key});

  @override
  Widget build(BuildContext context) {
    String? image;
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state.currentTrack?.image != image,
        builder: (context, state) {
          final currentTrack = state.currentTrack;
          if (currentTrack == null) {
            return const EmptyWidget();
          }
          image = currentTrack.image;
          return playerCover(context, currentTrack.image);
        });
  }
}
