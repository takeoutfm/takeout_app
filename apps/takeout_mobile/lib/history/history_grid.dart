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
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';
import 'package:takeout_mobile/pages/spiff/spiff_details.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_details.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

const historyGridEdgeInset = 20.0;
const historyGridSpacing = 12.0;

class SliverHistoryGrid extends StatelessWidget {
  final List<HistoryEntry> _history;
  final EdgeInsetsGeometry padding;

  const SliverHistoryGrid(
    this._history, {
    super.key,
    this.padding = const EdgeInsetsGeometry.all(historyGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: coverGridWidth,
        childAspectRatio: 1.0,
        crossAxisSpacing: historyGridSpacing,
        mainAxisSpacing: historyGridSpacing,
        children: [
          ..._history.map(
            (h) => SliverGridTile(
              image: historyTile(context, h.image),
              title: h.title,
              // subtitle: h.spiff.creator,
              dateTime: h.dateTime,
              onTap: () => _onTap(context, h),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, HistoryEntry entry) {
    if (entry is SpiffHistory) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          // TODO consider making spiff refreshable. Need original reference or uri.
          builder: (_) =>
              SpiffDetailsPage(title: entry.spiff.title, value: entry.spiff),
        ),
      );
    } else if (entry is VideoHistory) {
      if (entry.isMovie) {
        final movie = context.search.findMovie(entry.title, year: entry.year);
        if (movie != null) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => MovieDetailsPage(movie)),
          );
        }
      } else if (entry.isTVEpisode) {
        ({int season, int episode})? parseSxEy(String input) {
          final m = RegExp(r'^S(\d{1,3})E(\d{1,3})$').firstMatch(input);
          final s = int.tryParse(m?.group(1) ?? '');
          final e = int.tryParse(m?.group(2) ?? '');
          if (s == null || e == null) return null;
          return (season: s, episode: e);
        }

        // TODO this isn't great but ok for now
        final se = parseSxEy(entry.video.collection ?? '');
        final episode = context.search.findTVEpisode(
          entry.title,
          year: entry.year,
          season: se?.season,
          episode: se?.episode,
        );
        if (episode != null) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) => TVEpisodeDetailsPage(episode),
            ),
          );
        }
      }
    }
  }
}
