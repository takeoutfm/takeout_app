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
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/tv/tvseries_details.dart';

const tvSeriesGridEdgeInset = 20.0;
const tvSeriesGridSpacing = 12.0;

class SliverTVSeriesGrid extends StatelessWidget {
  final List<TVSeries> _series;
  final EdgeInsetsGeometry padding;

  const SliverTVSeriesGrid(
    this._series, {
    super.key,
    this.padding = const EdgeInsetsGeometry.all(tvSeriesGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: posterGridWidth,
        childAspectRatio: posterAspectRatio,
        crossAxisSpacing: tvSeriesGridSpacing,
        mainAxisSpacing: tvSeriesGridSpacing,
        children: [
          ..._series.map(
            (s) => InkWell(
              onTap: () => _onTap(context, s),
              // TODO figure out how to add material splash it seemed
              // be happening underneath the image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GridTile(
                  footer: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    child: GridTileBar(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      title: Text(s.name, style: context.gridTitle),
                    ),
                  ),
                  child: gridPoster(context, s.image),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, TVSeries series) {
    push(context, builder: (_) => TVSeriesDetailsPage(series));
  }
}
