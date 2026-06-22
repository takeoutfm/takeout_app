import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/podcast/series_details.dart';

const seriesGridEdgeInset = 20.0;
const seriesGridSpacing = 12.0;

class SliverSeriesGrid extends StatelessWidget {
  final List<Series> _series;
  final bool subtitle;
  final EdgeInsetsGeometry padding;

  const SliverSeriesGrid(
    this._series, {
    super.key,
    this.subtitle = true,
    this.padding = const EdgeInsetsGeometry.all(seriesGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: seriesGridSpacing,
        mainAxisSpacing: seriesGridSpacing,
        children: [
          ..._series.map(
            (s) => InkWell(
              onTap: () => _onTap(context, s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GridTile(
                  footer: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    child: GridTileBar(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      title: Text(s.title),
                      subtitle: subtitle ? Text(s.creator) : null,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: gridCover(context, s.image),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, Series s) {
    push(
      context,
      builder: (context) {
        return SeriesDetailsPage(s);
      },
    );
  }
}
