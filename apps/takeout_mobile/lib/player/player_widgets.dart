import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/playing.dart';
import 'package:takeout_lib/player/repeat.dart';
import 'package:takeout_lib/player/seekbar.dart';
import 'package:takeout_mobile/app/context.dart';

mixin PlayerWidgets {
  Widget playerImage(BuildContext context, {bool allowControl = false}) {
    MediaTrack? track = context.player.state.currentTrack;
    bool isPlaying = false;
    bool isBuffering = false;
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerProcessingEvent &&
              (isPlaying != state.playing || isBuffering != state.buffering) ||
          state is PlayerLoad ||
          state is PlayerIndexChange ||
          state is PlayerTrackChange,
      builder: (context, state) {
        debugPrint('playerImage');
        if (state is PlayerPositionEvent) {
          track = state.currentTrack;
          isPlaying = state.playing;
          isBuffering = state.buffering;
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: tileCover(context, track?.image ?? ''),
            ),
            if (allowControl)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: isBuffering
                    ? CircularProgressIndicator()
                    : IconButton(
                        iconSize: 48,
                        color: Colors.white,
                        onPressed: () => isPlaying
                            ? context.player.pause()
                            : context.player.play(),
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
              ),
          ],
        );
      },
    );
  }

  Widget playerTitle(BuildContext context) {
    final track = context.player.state.currentTrack;
    String title = track?.title ?? '';
    String artist = track?.creator ?? '';
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerLoad ||
          state is PlayerIndexChange ||
          state is PlayerTrackChange,
      builder: (context, state) {
        // debugPrint('playerTitle');
        if (state is PlayerLoad ||
            state is PlayerIndexChange ||
            state is PlayerTrackChange) {
          final currentTrack = state.currentTrack;
          if (currentTrack != null) {
            title = currentTrack.title;
            artist = currentTrack.creator;
          }
        }
        return title.isNotEmpty
            ? GestureDetector(
                onTap: () => context.showArtist(artist),
                child: Text(title),
              )
            : const EmptyWidget();
      },
    );
  }

  Widget playerArtist(BuildContext context) {
    final track = context.player.state.currentTrack;
    String artist = track?.creator ?? '';
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerLoad || state is PlayerIndexChange,
      builder: (context, state) {
        // debugPrint('playerArtist');
        if (state is PlayerLoad || state is PlayerIndexChange) {
          final currentTrack = state.currentTrack;
          if (currentTrack != null) {
            artist = currentTrack.creator;
          }
        }
        return artist.isNotEmpty ? Text(artist) : const EmptyWidget();
      },
    );
  }

  Widget playPauseButton(BuildContext context, {double? iconSize}) {
    bool playing = false;
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerPositionEvent && state.playing != playing,
      builder: (context, state) {
        if (state is PlayerPositionEvent) {
          playing = state.playing;
        }
        return IconButton(
          icon: Icon(playing ? Icons.pause : Icons.play_arrow, size: iconSize),
          onPressed: () =>
              playing ? context.player.pause() : context.player.play(),
        );
      },
    );
  }

  Widget playerProgressBar(BuildContext context) {
    double value = 0;
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerIndexChange || state is PlayerPositionEvent,
      builder: (context, state) {
        if (state.spiff.isEmpty || state.spiff.isLive) {
          // no seekbar streams
          return const EmptyWidget();
        }
        if (state is PlayerPositionEvent) {
          value = state.position.inMilliseconds / state.duration.inMilliseconds;
        }
        return RepaintBoundary(child: LinearProgressIndicator(value: value));
      },
    );
  }

  Widget playerSeekBar(BuildContext context) {
    final player = context.player;
    return BlocBuilder<Player, PlayerEvent>(
      bloc: player,
      buildWhen: (_, state) =>
          state is PlayerIndexChange || state is PlayerPositionEvent,
      builder: (context, state) {
        if (state.spiff.isEmpty || state.spiff.isLive) {
          // no seekbar streams
          return const EmptyWidget();
        }
        if (state is PlayerIndexChange) {
          return _seekBar(player, Duration.zero, Duration.zero, state.playing);
        } else if (state is PlayerPositionEvent) {
          return _seekBar(
            player,
            state.duration,
            state.position,
            state.playing,
          );
        }
        return const EmptyWidget();
      },
    );
  }

  Widget repeatButton() {
    return Builder(
      builder: (context) {
        // debugPrint('repeatButton');
        final state = context.watch<NowPlayingCubit>().state;
        final nowPlaying = context.nowPlaying;
        switch (state.nowPlaying.repeat) {
          case RepeatMode.none || null:
            return IconButton(
              icon: const Icon(Icons.repeat),
              onPressed: () => nowPlaying.repeatMode(RepeatMode.all),
            );
          case RepeatMode.all:
            return IconButton(
              icon: const Icon(Icons.repeat),
              isSelected: true,
              onPressed: () => nowPlaying.repeatMode(RepeatMode.one),
            );
          case RepeatMode.one:
            return IconButton(
              icon: const Icon(Icons.repeat_one),
              isSelected: true,
              onPressed: () => nowPlaying.repeatMode(RepeatMode.none),
            );
        }
      },
    );
  }

  Widget remainingTime(BuildContext context) {
    String? text;
    Duration position = Duration.zero;
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerIndexChange ||
          (state is PlayerPositionEvent &&
              state.position.inSeconds != position.inSeconds),
      builder: (context, state) {
        if (state is PlayerPositionEvent) {
          position = state.position;
          final r = state.duration - position;
          text = _durationText(r);
        }
        final t = text;
        return t != null ? Text(t) : EmptyWidget();
      },
    );
  }

  Widget positionTime(BuildContext context) {
    String? text;
    Duration position = Duration.zero;
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
      state is PlayerIndexChange ||
          (state is PlayerPositionEvent &&
              state.position.inSeconds != position.inSeconds),
      builder: (context, state) {
        if (state is PlayerPositionEvent) {
          position = state.position;
          text = _durationText(position);
        }
        final t = text;
        return t != null ? Text(t) : EmptyWidget();
      },
    );
  }

  String _durationText(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return'${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Widget _seekBar(
    Player player,
    Duration duration,
    Duration position,
    bool playing,
  ) {
    return RepaintBoundary(
      child: SeekBar(
        playing: playing,
        duration: duration,
        position: position,
        onChangeEnd: (newPosition) => player.seek(newPosition),
      ),
    );
  }
}
