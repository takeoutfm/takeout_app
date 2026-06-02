import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';

class GenrePage extends ClientPage<GenreView> {
  final String _genre;

  GenrePage(this._genre, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.moviesGenre(_genre, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, GenreView state) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(title: Text(_genre)),
            if (state.movies.isNotEmpty)
              SliverMovieGrid(_sortByTitle(state.movies)),
          ],
        ),
      ),
    );
  }

  // Note this modifies the original list.
  List<Movie> _sortByTitle(List<Movie> movies) {
    movies.sort((a, b) => a.sortTitle.compareTo(b.sortTitle));
    return movies;
  }
}