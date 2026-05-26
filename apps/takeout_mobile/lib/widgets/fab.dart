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
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/context.dart';

class FabWidget extends StatelessWidget {
  const FabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Player, PlayerEvent>(
      builder: (context, state) {
        bool playing = false;
        double? progress;

        if (context.app.state.index == NavigationIndex.player) {
          // hide fab on player page
          return const EmptyWidget();
        }
        if (state is PlayerInit ||
            state is PlayerReady ||
            state is PlayerLoad ||
            state is PlayerStop) {
          // hide fab
          return const EmptyWidget();
        }
        if (state is PlayerPositionEvent) {
          playing = state.playing;
          progress = state.progress;
          if (state.buffering) {
            progress = null;
          }
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton(
              onPressed: () =>
                  playing ? context.player.pause() : context.player.play(),
              shape: const CircleBorder(),
              child: playing
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
            ),
            IgnorePointer(
              child: SizedBox(
                width: 52, // non-mini FAB is 56, progress is 4
                height: 52,
                child: CircularProgressIndicator(value: progress),
              ),
            ),
          ],
        );
      },
    );
  }
}
