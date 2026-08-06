import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_details.dart';
import 'package:takeout_mobile/widgets/focus_item.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

const tvEpisodeGridEdgeInset = 20.0;
const tvEpisodeGridSpacing = 12.0;

class SliverTVEpisodeGrid extends StatelessWidget {
  final List<TVEpisode> _episodes;
  final EdgeInsetsGeometry padding;

  const SliverTVEpisodeGrid(
    this._episodes, {
    super.key,
    this.padding = const EdgeInsetsGeometry.all(tvEpisodeGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: posterGridWidth,
        childAspectRatio: posterAspectRatio,
        crossAxisSpacing: tvEpisodeGridSpacing,
        mainAxisSpacing: tvEpisodeGridSpacing,
        children: [
          ..._episodes.map(
            (e) => SliverGridTile(
              image: MediaProgress.tvEpisode(
                e,
                gridTVEpisode(context, e.image),
              ),
              title: e.name,
              titleMaxLines: 2,
              height: 44,
              badge: '${e.episode}',
              onTap: () => _onTap(context, e),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, TVEpisode episode) {
    push(context, builder: (_) => TVEpisodeDetailsPage(episode));
  }
}
