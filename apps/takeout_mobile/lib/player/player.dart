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

// This file was heavily based on the audio_service example app located here:
// https://github.com/ryanheise/audio_service

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/scaffold.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/player/player_sheet.dart';
import 'package:takeout_mobile/player/player_widgets.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

class PlayerWidget extends StatelessWidget with PlayerWidgets {
  const PlayerWidget({super.key});

  void _onSyncPlaylist(BuildContext context) {
    context.playlist.sync();
  }

  void _onPlaylists(BuildContext context) {
    showPlaylistSelect(context, (playlist) {
      // avoid async context twice - use context from globalAppKey
      final context = globalAppKey.currentContext;
      if (context != null && context.mounted) {
        context.clientRepository.playlist(id: playlist.id).then((spiff) {
          final context = globalAppKey.currentContext;
          if (context != null && context.mounted) {
            context.play(spiff);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= size.height;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -300) {
          // swiping up
          _showQueue(context);
        }
      },
      child: PlayerScaffold(
        body: (Color? color, {Spiff? spiff}) {
          MediaTrack? track;
          if (spiff?.isNotEmpty ?? false) {
            track = spiff?[spiff.index];
          }
          if (spiff == null || track == null) {
            return EmptyWidget();
          }
          // return CustomScrollView(
          //   slivers: [
          //     SliverToBoxAdapter(
          //       child: const SizedBox(
          //         height: 500,
          //         child: ColoredBox(color: Colors.blue),
          //       ),
          //     ),
          //   ],
          // );
          return SliverStack(
            slivers: [
              SliverMenuBar(
                // title: track.title,
                allowBack: false,
                items: [
                  PopupItem.syncPlaylist(context, _onSyncPlaylist),
                  PopupItem.playlists(context, _onPlaylists),
                  PopupItem.stop(context, 'Stop', (context) {
                    context.player.stop();
                  }),
                ],
              ),
              SliverBox(
                padding: EdgeInsets.all(6),
                child: Builder(
                  builder: (context) {
                    if (isWide) {
                      // wide view
                      return IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(20),
                          child: Row(
                            // crossAxisAlignment: .center,
                            children: [
                              playerImage(
                                context,
                                allowControl: false,
                                fill: true,
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 0,
                                  ),
                                  child: _details(
                                    context,
                                    spiff,
                                    color,
                                    center: true,
                                    spacing: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    // tall view
                    return Column(
                      crossAxisAlignment: .center,
                      children: [
                        playerImage(context, allowControl: false, fill: true),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Builder(
                    builder: (context) {
                      return isWide
                          ? const EmptyWidget()
                          : _details(context, spiff, color);
                    },
                  ),
                ),
              ),
            ],
            footer: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              children: [
                // SizedBox(height: 2),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  onPressed: () => _showQueue(context),
                ),
                // CircleButton.openSheet(onTap: () => _showQueue(context)),
                // SizedBox(height: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _details(
    BuildContext context,
    Spiff spiff,
    Color? color, {
    bool center = false,
    double spacing = 6,
  }) {
    MediaTrack? track;
    if (spiff.isNotEmpty) {
      track = spiff[spiff.index];
    }
    final scheme = ColorScheme.of(context);
    return Column(
      mainAxisAlignment: center ? .center : .start,
      children: [
        playerTitle(context, style: context.playerHeader),
        SizedBox(height: spacing),
        playerArtist(context, style: context.playerTitle),
        SizedBox(height: spacing),
        if (spiff.isMusic)
          Wrap(
            children: [
              Text(
                '${track?.album} (${track?.year}) ',
                style: context.playerSubtitle,
              ),
            ],
          ),
        if (spiff.isLive)
          Wrap(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.onSurface,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        // color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (spiff.isMusic) ...[
          SizedBox(height: spacing),
          Row(
            children: [
              repeatButton(),
              Expanded(child: ExcludeFocus(child: playerSeekBar(context))),
              // Expanded(child: newSeekBar(context)),
            ],
          ),
        ],
        SizedBox(height: spacing * 2),
        playerControls(context),
      ],
    );
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) =>
            playerSheet(context, scrollController),
      ),
    );
  }

  Widget playerControls(BuildContext context) {
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) => state is PlayerPlay || state is PlayerPause,
      builder: (context, state) {
        if (state.spiff.isEmpty) {
          return const EmptyWidget();
        }
        if (state is PlayerPlay || state is PlayerPause) {
          return _controlButtons(context, state as PlayerPositionEvent);
        } else {
          return IconButton(
            autofocus: true,
            icon: const Icon(Icons.play_arrow),
            // iconSize: 64.0,
            onPressed: () => context.player.play(),
          );
        }
        // return const EmptyWidget();
      },
    );
  }

  Widget playerQueue(BuildContext context) {
    final player = context.player;
    return BlocBuilder<Player, PlayerEvent>(
      bloc: player,
      buildWhen: (_, state) =>
          state is PlayerLoad ||
          state is PlayerIndexChange ||
          state is PlayerPlay ||
          state is PlayerPause,
      builder: (context, state) {
        if (state.spiff.isLive) {
          return _liveTrackList(context);
        }
        if (state.spiff.length == 1) {
          // hide track list
          return const EmptyWidget();
        }
        return _trackList(context, player, state);
      },
    );
  }

  Widget _controlButtons(BuildContext context, PlayerPositionEvent state) {
    final player = context.player;
    final isPodcast = state.spiff.isPodcast;
    final isLive = state.spiff.isLive;
    final isMusic = state.spiff.isMusic;
    final playing = state.playing;
    final buffering = state.buffering;
    return Wrap(
      // mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        // if (isMusic) _repeatButton(),
        if (!isLive)
          IconButton(
            icon: const Icon(Icons.skip_previous),
            iconSize: 32,
            onPressed: state.hasPrevious ? () => player.skipToPrevious() : null,
          ),
        if (isPodcast)
          IconButton(
            icon: const Icon(Icons.replay_10_outlined),
            iconSize: 32,
            onPressed: () => player.skipBackward(),
          ),
        if (buffering)
          // CircularProgressIndicator is 64 by default
          // 22 padding keeps the screen in-place
          Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: SizedBox(
              width: 24,
              height: 24,
              child: const CircularProgressIndicator(),
            ),
          )
        else if (playing)
          CircleButton(
            autofocus: true,
            icon: Icons.pause,
            onTap: () => player.pause(),
          )
        else
          CircleButton(
            autofocus: true,
            icon: Icons.play_arrow,
            onTap: () => player.play(),
          ),
        // stopButton(),
        if (isPodcast)
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.forward_30_outlined),
            onPressed: () => player.skipForward(),
          ),
        if (!isLive)
          IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 32,
            onPressed: state.hasNext ? () => player.skipToNext() : null,
          ),
        // if (isMusic) _invisibleButton(),
      ],
    );
  }

  Widget _invisibleButton() {
    return const SizedBox.square(dimension: 36 + 16);
  }

  void _onArtist(BuildContext context, String artist) {
    context.showArtist(artist);
  }

  Widget _trackList(BuildContext context, Player player, PlayerEvent state) {
    final tracks = state.spiff.playlist.tracks;
    final sameArtwork = tracks.every((t) => t.image == tracks.first.image);
    // final playing = (state is PlayerPositionEvent) && state.playing;
    return Column(
      children: [
        ...List.generate(tracks.length * 2 - 1, (i) {
          final index = i ~/ 2;
          return i.isEven
              ? CoverTrackListTile.mediaTrack(
                  context,
                  tracks[index],
                  showCover: true,
                  //!sameArtwork,
                  trailing: _cachedIcon(),
                  nowPlaying: index == state.currentIndex,
                  // TODO
                  onTap: () => player.playIndex(index),
                  onLongPress: () {
                    _onArtist(context, tracks[index].creator);
                  },
                )
              : Divider();
        }),
      ],
    );
  }

  Widget _liveTrackList(BuildContext context) {
    return Builder(
      builder: (context) {
        final history = context.watch<HistoryCubit>();
        // final player = context.watch<Player>();
        final tracks = List<StreamHistory>.from(history.state.history.stream);
        tracks.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        final sameArtwork = tracks.every((t) => t.image == tracks.first.image);
        return Column(
          children: [
            ...List.generate(
              tracks.length,
              (index) => CoverTrackListTile.liveTrack(
                context,
                tracks[index],
                showCover: !sameArtwork,
                // selected:
                //     player.state.currentTrack?.title == tracks[index].title,
                dateTime: tracks[index].dateTime,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _cachedIcon() {
    // TODO
    return null;
  }
}
