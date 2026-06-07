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

import 'dart:io';

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
import 'package:takeout_mobile/player/player_widgets.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/smooth_media_progress.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

class PlayerWidget2 extends StatelessWidget with PlayerWidgets {
  const PlayerWidget2({super.key});

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

  List<Widget> actions(BuildContext context) {
    return <Widget>[
      popupMenu(context, [
        PopupItem.syncPlaylist(context, _onSyncPlaylist),
        PopupItem.playlists(context, _onPlaylists),
        PopupItem.delete(context, 'Stop', (context) {
          context.player.stop();
        }),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('player2 build');
    return PlayerScaffold(
      body: (Color? color, {Spiff? spiff}) {
        debugPrint('player2 pre build scaffold');
        MediaTrack? track;
        if (spiff?.isNotEmpty ?? false) {
          track = spiff?[spiff.index];
        }
        if (spiff == null || track == null) {
          return EmptyWidget();
        }
        debugPrint('player2 build scaffold');
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
        return Focus(
          canRequestFocus: false,
          descendantsAreFocusable: true,
          child: CustomScrollView(
            slivers: [
              SliverMenuBar(
                title: track.title,
                allowBack: false,
                items: [
                  // PopupItem.play(
                  //   context,
                  //       (_) => _onPlay(context, state),
                  // ),
                  // PopupItem.shuffle(
                  //   context,
                  //       (_) => _onShufflePlay(context),
                  // ),
                  // PopupItem.download(
                  //   context,
                  //       (_) => _onDownload(context, state),
                  // ),
                  // PopupItem.playlistAppend(
                  //   context,
                  //       (_) => _onPlaylistAppend(context, state),
                  // ),
                  // PopupItem.divider(),
                  // PopupItem.link(
                  //   context,
                  //   'MusicBrainz Release',
                  //       (_) => launchUrl(Uri.parse(releaseUrl)),
                  // ),
                  // PopupItem.link(
                  //   context,
                  //   'MusicBrainz Release Group',
                  //       (_) => launchUrl(Uri.parse(releaseGroupUrl)),
                  // ),
                  PopupItem.divider(),
                  // PopupItem.reload(
                  //   context,
                  //       (_) => reloadPage(context),
                  // ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsetsGeometry.all(20),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          playerImage(context, allowControl: true),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SizedBox(
                              height: 255,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: AppTextStyle.musicReleaseTitle,
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    track.creator,
                                    style: AppTextStyle.musicArtist.copyWith(
                                      decoration: .underline,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Wrap(
                                    children: [
                                      Text(
                                        '${track.year}',
                                        style: AppTextStyle.musicYear,
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        track.album,
                                        style: AppTextStyle.musicYear,
                                      ),
                                    ],
                                  ),

                                  if (spiff.isNotLive) ...[
                                    // const SizedBox(height: 12),
                                    Spacer(),
                                    playerControls(context),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (spiff.isNotLive) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            repeatButton(),
                            // Expanded(child: playerSeekBar(context)),
                            Expanded(child: newSeekBar(context)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.50),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: playerQueue(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget newSeekBar(BuildContext context) {
    final player = context.player;
    Duration duration = .zero; // TODO get current duration
    return BlocBuilder<Player, PlayerEvent>(
      bloc: player,
      buildWhen: (_, state) => state is PlayerDurationChange,
      builder: (context, state) {
        if (state is PlayerDurationChange) {
          duration = state.duration;
        }
        debugPrint('duration is $duration');
        return RepaintBoundary(
          child: SmoothMediaProgress(
            positionStream: player.stream
                .where((state) => state is PlayerPositionEvent)
                .cast<PlayerPositionEvent>()
                .map((state) => state.position),
            duration: duration,
            onSeek: (position) => player.seek(position),
            targetFps: Platform.isLinux ? 4 : 60,
          ),
        );
      },
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
        if (state is PlayerLoad || state is PlayerIndexChange) {
          return _trackList(context, player, state);
        } else if (state is PlayerIndexChange) {
          return _trackList(context, player, state);
        } else if (state is PlayerPositionEvent) {
          return _trackList(context, player, state);
        }
        return const EmptyWidget();
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
          Container(
            padding: const EdgeInsets.all(22.0),
            child: const CircularProgressIndicator(),
          )
        else if (playing)
          CircleButton(icon: Icons.pause, onTap: () => player.pause())
        else
          CircleButton(icon: Icons.play_arrow, onTap: () => player.play()),
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
        if (isMusic) _invisibleButton(),
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
        ...List.generate(
          tracks.length,
          (index) => CoverTrackListTile.mediaTrack(
            context,
            tracks[index],
            showCover: true,
            //!sameArtwork,
            trailing: _cachedIcon(),
            // selected: index == state.currentIndex,
            nowPlaying: index == state.currentIndex,
            // TODO
            onTap: () => player.playIndex(index),
            onLongPress: () {
              _onArtist(context, tracks[index].creator);
            },
          ),
        ),
      ],
    );
  }

  Widget _liveTrackList(BuildContext context) {
    return Builder(
      builder: (context) {
        final history = context.watch<HistoryCubit>();
        final player = context.watch<Player>();
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
                selected:
                    player.state.currentTrack?.title == tracks[index].title,
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
