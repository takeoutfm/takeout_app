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
  final sameArtwork = tracks.every((t) => t.image == tracks.first.image);
  // final playing = (state is PlayerPositionEvent) && state.playing;

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
              //!sameArtwork,
              // trailing: _cachedIcon(),
              nowPlaying: index == state.currentIndex,
              // TODO
              onTap: () => player.playIndex(index),
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
