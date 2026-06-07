import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/builder.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/player/player_widgets.dart';

class MiniPlayer extends StatelessWidget with PlayerWidgets {
  const MiniPlayer({super.key});

  static const height = 72.0;

  @override
  Widget build(BuildContext context) {
    MediaTrack? track;
    debugPrint('miniplayer build');
    track = context.player.state.currentTrack;
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (_, state) =>
          state is PlayerLoad ||
          state is PlayerIndexChange ||
          state is PlayerTrackChange,
      builder: (context, state) {
        if (state is PlayerLoad ||
            state is PlayerIndexChange ||
            state is PlayerTrackChange) {
          track = state.currentTrack;
        }
        final t = track;
        debugPrint('track ${t?.title}');
        return t != null
            ? FutureBuilder(
                future: getImageBackgroundColor(context, t.image),
                builder: (context, snapshot) {
                  final color = snapshot.data;
                  return _build(context, state, t, color);
                },
              )
            : EmptyWidget();
      },
    );
  }

  Widget _build(
    BuildContext context,
    PlayerEvent state,
    MediaTrack track,
    Color? backgroundColor,
  ) {
    bool playing = false;
    debugPrint('miniplayer _build');

    // if (state is PlayerPositionEvent) {
    //   if (state.spiff.isNotLive) {
    //     final value =
    //         state.position.inMilliseconds / state.duration.inMilliseconds;
    //     final slider = RepaintBoundary(
    //       child: LinearProgressIndicator(value: value),
    //     );
    //     // final slider = RepaintBoundary(child: SizedBox(
    //     //   height: 4,
    //     //   child: Stack(
    //     //     children: [
    //     //       Container(
    //     //         color: Colors.grey.shade700,
    //     //       ),
    //     //       FractionallySizedBox(
    //     //         widthFactor: value,
    //     //         alignment: Alignment.centerLeft,
    //     //         child: Container(
    //     //           color: Theme.of(context).colorScheme.primary,
    //     //         ),
    //     //       ),
    //     //     ],
    //     //   ),
    //     // ));
    //     final duration = state.duration - state.position;
    //     remaining = RemainingTime(duration);
    //
    //     progress = slider;
    //   }
    //   playing = state.playing;
    // }

    return Container(
      color: backgroundColor,
      padding: EdgeInsetsGeometry.all(5),
      height: height,
      child: Row(
        mainAxisAlignment: .start,
        children: [
          playerImage(context),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Column(
                  spacing: 0,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(track.title, style: AppTextStyle.miniPlayerTitle),
                    // Text(track.creator, style: AppTextStyle.miniPlayerSubtitle),
                    playerTitle(context),
                    playerArtist(context),
                    playerProgressBar(context),
                  ],
                ),
                Align(
                  alignment: .centerRight,
                  child: SizedBox(
                    height: 30,
                    width: 50,
                    child: RepaintBoundary(child: remainingTime(context)),
                  ),
                ),
              ],
            ),
          ),
          if (playing)
            IconButton(
              icon: Icon(Icons.pause, size: height * .4),
              onPressed: () => context.player.pause(),
            ),
          if (playing == false)
            IconButton(
              icon: Icon(Icons.play_arrow, size: height * .4),
              onPressed: () => context.player.play(),
            ),
          IconButton(
            icon: Icon(Icons.queue_music, size: height * .5),
            onPressed: () => context.app.player(),
          ),
        ],
      ),
    );
  }
}

class RemainingTime extends StatelessWidget {
  final Duration duration;

  const RemainingTime(this.duration, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: Text(format(duration)));
  }

  String format(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
