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
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

Widget playerSheet(BuildContext context, ScrollController scrollController) {
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
        return _liveTrackListView(context, scrollController);
      }
      if (state.spiff.length == 1) {
        // hide track list
        return const EmptyWidget();
      }
      return _trackListView(context, scrollController, player, state);
    },
  );
}

Widget _trackListView(
  BuildContext context,
  ScrollController scrollController,
  Player player,
  PlayerEvent state,
) {
  final tracks = state.spiff.playlist.tracks;

  return ListView.builder(
    controller: scrollController, // 👈 required, not optional
    itemCount: tracks.length * 2 - 1,
    itemBuilder: (context, i) {
      final index = i ~/ 2;
      return i.isEven
          ? CoverTrackListTile.mediaTrack(
              context,
              tracks[index],
              showCover: true,
              nowPlaying: index == state.currentIndex,
              onTap: () {
                player.playIndex(index);
                Navigator.pop(context);
              },
              // onLongPress: () {
              //   _onArtist(context, tracks[index].creator);
              // },
            )
          : Divider();
    },
  );
}

Widget _liveTrackListView(
  BuildContext context,
  ScrollController scrollController,
) {
  return Builder(
    builder: (context) {
      final history = context.watch<HistoryCubit>();
      // final player = context.watch<Player>();
      final tracks = List<StreamHistory>.from(history.state.history.stream);
      if (tracks.isEmpty) {
        return EmptyWidget();
      }
      tracks.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final sameArtwork = tracks.every((t) => t.image == tracks.first.image);
      return ListView.builder(
        controller: scrollController,
        itemCount: tracks.length * 2 - 1,
        itemBuilder: (context, i) {
          final index = i ~/ 2;
          return i.isEven
              ? CoverTrackListTile.liveTrack(
                  context,
                  tracks[index],
                  showCover: !sameArtwork,
                  // selected:
                  //     player.state.currentTrack?.title == tracks[index].title,
                  dateTime: tracks[index].dateTime,
                )
              : Divider();
        },
      );
    },
  );
}
