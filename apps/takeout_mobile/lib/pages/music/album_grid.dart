import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

const albumGridEdgeInset = 20.0;
const albumGridSpacing = 12.0;

class SliverAlbumGrid extends StatelessWidget {
  final List<MediaAlbum> _albums;
  final bool subtitle;
  final EdgeInsetsGeometry padding;

  const SliverAlbumGrid(
    this._albums, {
    super.key,
    this.subtitle = true,
    this.padding = const EdgeInsetsGeometry.all(albumGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: albumGridSpacing,
        mainAxisSpacing: albumGridSpacing,
        children: [
          ..._albums.map(
            (a) => SliverGridTile(
              image: gridCover(context, a.image),
              title: a.album,
              subtitle: a.creator,
              onTap: () => _onTap(context, a),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, MediaAlbum album) {
    push(
      context,
      builder: (context) {
        if (album is Release) {
          return ReleaseDetailsPage(album);
        }
        throw UnimplementedError;
      },
    );
  }
}
