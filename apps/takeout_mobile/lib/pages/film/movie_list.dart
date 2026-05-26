
import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';

class MovieListWidget extends StatelessWidget {
  final List<Movie> _movies;

  const MovieListWidget(this._movies, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._movies.asMap().keys.toList().map(
              (index) => ListTile(
            onTap: () => _onTapped(context, _movies[index]),
            leading: tilePoster(context, _movies[index].image),
            subtitle: Text(
              merge([_movies[index].year.toString(), _movies[index].rating]),
            ),
            title: Text(_movies[index].title),
          ),
        ),
      ],
    );
  }

  void _onTapped(BuildContext context, Movie movie) {
    push(context, builder: (_) => MovieDetailsPage(movie));
  }
}