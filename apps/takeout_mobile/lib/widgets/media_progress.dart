import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/offset_repository.dart';

class MediaProgress extends StatelessWidget {
  final OffsetIdentifier id;
  final Widget image;
  final Color color;

  const MediaProgress.movie(
    Movie movie,
    this.image, {
    this.color = Colors.red,
    super.key,
  }) : id = movie;

  const MediaProgress.episode(
      Episode episode,
      this.image, {
        this.color = Colors.red,
        super.key,
      }) : id = episode;

  const MediaProgress.tvEpisode(
      TVEpisode episode,
      this.image, {
        this.color = Colors.red,
        super.key,
      }) : id = episode;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OffsetCacheCubit>().state;
    final value = state.value(id);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          image,
          if (value != null && value > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 9,
                backgroundColor: Colors.white24.withValues(alpha: 0.6),
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
