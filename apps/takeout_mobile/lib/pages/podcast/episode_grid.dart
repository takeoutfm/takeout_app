import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/podcast/episode_details.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

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
              subtitle: 'FIXME',
              image: gridPodcastEpisode(context, e.image),
              onTap: () => _onTap(context, e),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitle(Episode e) {
    return RelativeDateWidget.from(e.date, suffix: e.creator);
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
