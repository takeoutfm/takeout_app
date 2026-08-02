import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/artist_details.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

const artistGridEdgeInset = 20.0;
const artistGridSpacing = 12.0;

class SliverArtistGrid extends StatelessWidget {
  final List<Artist> _artists;
  final EdgeInsetsGeometry padding;

  const SliverArtistGrid(
    this._artists, {
    super.key,
    this.padding = const EdgeInsetsGeometry.all(artistGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: artistGridSpacing,
        mainAxisSpacing: artistGridSpacing,
        children: [
          ..._artists.map(
            (a) => SliverGridTile(
              image: gridCover(context, a.image ?? ''),
              title: a.name,
              subtitle: a.genre?.titleCased ?? '',
              onTap: () => _onTap(context, a),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, Artist artist) {
    push(context, builder: (context) => ArtistDetailsPage(artist));
  }
}
