// Copyright 2026 defsub
//
// This file is part of TakeoutFM.
//
// TakeoutFM is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// TakeoutFM is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with TakeoutFM.  If not, see <https://www.gnu.org/licenses/>.

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