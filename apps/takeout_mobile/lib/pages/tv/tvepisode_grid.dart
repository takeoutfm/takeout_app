import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_details.dart';
import 'package:takeout_mobile/widgets/focus_item.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';

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
            (e) => FocusItem(
              child: InkWell(
                onTap: () => _onTap(context, e),
                // TODO figure out how to add material splash it seemed
                // be happening underneath the image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GridTile(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        MediaProgress.tvEpisode(e, gridTVEpisode(context, e.image)),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${e.episode}',
                              style: context.labelSmall?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 44,
                            color: Colors.black.withValues(alpha: 0.65),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Text(
                              e.name,
                              style: context.gridTitle,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // child: ClipRRect(
                //   borderRadius: BorderRadius.circular(16),
                //   child: GridTile(
                //
                //
                //     footer: Material(
                //       color: Colors.transparent,
                //       clipBehavior: Clip.antiAlias,
                //       child: GridTileBar(
                //         backgroundColor: Colors.black.withValues(alpha: 0.65),
                //         title: Text(
                //           e.name,
                //           style: context.gridTitle,
                //           maxLines: 2,
                //           softWrap: true,
                //         ),
                //       ),
                //     ),
                //     child: MediaProgress.tvEpisode(
                //       e,
                //       gridTVEpisode(context, e.image),
                //     ),
                //   ),
                // ),
              ),
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
