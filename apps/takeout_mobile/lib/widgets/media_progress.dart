import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_mobile/widgets/focus_item.dart';

class MediaProgress extends StatelessWidget {
  final OffsetIdentifier id;
  final Widget image;
  final Color color;

  const MediaProgress.movie(
    Movie movie,
    this.image, {
    this.color = Colors.yellow,
    super.key,
  }) : id = movie;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OffsetCacheCubit>().state;
    final value = state.value(id);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          image,
          // Progress bar overlay at bottom
          if (value != null && value > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
        ],
      ),
    );
  }
}
