import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';
import 'package:takeout_mobile/pages/podcast/episode_details.dart';
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
    _episodes.forEach((e) {
      print(e.title);
      print(e.author);
      print(e.image);
    });
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: episodeGridSpacing,
        mainAxisSpacing: episodeGridSpacing,
        children: [
          ..._episodes.map(
                (e) => InkWell(
              onTap: () => _onTap(context, e),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GridTile(
                  footer: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    child: GridTileBar(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      title: Text(e.title),
                      subtitle: subtitle ? _subtitle(e) : null,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: gridPodcastEpisode(context, e.image),
                  ),
                ),
              ),
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
