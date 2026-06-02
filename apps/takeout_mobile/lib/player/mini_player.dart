import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  static const height = 72.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<Player>().state;
    final track = state.currentTrack;
    if (track == null) {
      return EmptyWidget();
    }

    Widget? progress;
    Widget? remaining;
    bool playing = false;
    if (state is PlayerPositionEvent) {
      if (state.spiff.isNotLive) {
        final value =
            state.position.inMilliseconds / state.duration.inMilliseconds;
        final slider = LinearProgressIndicator(value: value);
        final duration = state.duration - state.position;
        remaining = Text(
          RegExp(
                r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$',
              ).firstMatch('$duration')?.group(1) ??
              '$duration',
          style: Theme.of(context).textTheme.bodyMedium,
        );

        progress = slider;
      }
      playing = state.playing;
    }

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: .start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: tileCover(context, track.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Column(
                  spacing: 3,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, style: AppTextStyle.miniPlayerTitle),
                    Text(track.creator, style: AppTextStyle.miniPlayerSubtitle),
                    ?progress,
                  ],
                ),
                if (remaining != null)
                  Align(alignment: .centerRight, child: remaining),
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
