// Copyright 2026 defsub
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/builder.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/player/player_widgets.dart';

class MiniPlayer extends StatelessWidget with PlayerWidgets {
  const MiniPlayer({super.key});

  static const height = 72.0;

  @override
  Widget build(BuildContext context) {
    MediaTrack? track;
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
    return GestureDetector(
      onTap: () => context.app.player(),
      child: Container(
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
            playPauseButton(context, iconSize: height * .4),
          ],
        ),
      ),
    );
  }
}
