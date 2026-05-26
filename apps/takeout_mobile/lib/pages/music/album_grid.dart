import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';

const albumGridEdgeInset = 20.0;
const albumGridSpacing = 12.0;

class AlbumGrid extends StatelessWidget {
  final List<MediaAlbum> _albums;
  final bool subtitle;
  final EdgeInsetsGeometry padding;

  const AlbumGrid(
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
            (a) => InkWell(
              onTap: () => _onTap(context, a),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GridTile(
                  footer: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    child: GridTileBar(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      title: Text(a.album),
                      subtitle: subtitle ? Text(a.creator) : null,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: gridCover(context, a.image),
                  ),
                ),
              ),
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
