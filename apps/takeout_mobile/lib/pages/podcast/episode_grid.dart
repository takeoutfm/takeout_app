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
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/podcast/episode_details.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

const episodeGridEdgeInset = 20.0;
const episodeGridSpacing = 12.0;

class SliverEpisodeGrid extends StatelessWidget {
  final List<Episode> _episodes;
  final bool subtitle;
  final EdgeInsetsGeometry padding;

  const SliverEpisodeGrid(
    this._episodes, {
    super.key,
    this.subtitle = true,
    this.padding = const EdgeInsetsGeometry.all(episodeGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: episodeGridSpacing,
        mainAxisSpacing: episodeGridSpacing,
        children: [
          ..._episodes.map(
            (e) => SliverGridTile(
              title: e.title,
              subtitle: null,
              dateTime: e.dateTime,
              image: gridPodcastEpisode(context, e.image),
              onTap: () => _onTap(context, e),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, Episode e) {
    push(
      context,
      builder: (context) {
        return EpisodeDetailsPage(e);
      },
    );
  }
}
