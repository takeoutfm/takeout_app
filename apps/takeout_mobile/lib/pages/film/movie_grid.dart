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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';
import 'package:takeout_mobile/widgets/focus_item.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

const movieGridEdgeInset = 20.0;
const movieGridSpacing = 12.0;

class SliverMovieGrid extends StatelessWidget {
  final List<Movie> _movies;
  final EdgeInsetsGeometry padding;

  const SliverMovieGrid(
    this._movies, {
    super.key,
    this.padding = const EdgeInsetsGeometry.all(movieGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: posterGridWidth,
        childAspectRatio: posterAspectRatio,
        crossAxisSpacing: movieGridSpacing,
        mainAxisSpacing: movieGridSpacing,
        children: [
          ..._movies.map(
            (m) => FocusItem(
              onTap: () => _onTap(context, m),
              child: SliverGridTile(
                image: MediaProgress.movie(m, gridPoster(context, m.image)),
                title: m.album,
                subtitle: '${m.year}',
                onTap: () => _onTap(context, m),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, Movie movie) {
    push(context, builder: (_) => MovieDetailsPage(movie));
  }
}
