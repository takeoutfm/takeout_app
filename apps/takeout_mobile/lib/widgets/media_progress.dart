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
