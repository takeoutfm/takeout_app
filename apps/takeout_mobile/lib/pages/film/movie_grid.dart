import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';

const movieGridEdgeInset = 20.0;
const movieGridSpacing = 12.0;

class MovieGrid extends StatelessWidget {
  final List<Movie> _movies;
  final EdgeInsetsGeometry padding;

  const MovieGrid(
    this._movies, {
    super.key,
    this.padding = const EdgeInsetsGeometry.all(movieGridEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: posterGridWidth,
        childAspectRatio: posterAspectRatio,
        crossAxisSpacing: movieGridSpacing,
        mainAxisSpacing: movieGridSpacing,
        children: [
          ..._movies.map(
            (m) => InkWell(
              onTap: () => _onTap(context, m),
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
                      title: Text(m.title),
                    ),
                  ),
                  child: MediaProgress.movie(m, gridPoster(context, m.image)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, Movie movie) {
    push(context, builder: (_) => MovieDetailsPage(movie));
  }
}
