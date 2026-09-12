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

import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/client/repository.dart';

class MovieRepository {
  final MovieProvider _provider;

  MovieRepository({
    required ClientRepository clientRepository,
    MovieProvider? provider,
  }) : _provider = provider ?? DefaultMovieProvider(clientRepository);

  Iterable<String> findByTitle(String query) {
    return _provider.findByTitle(query);
  }

  Movie? findMovie(String title, {int? year}) {
    return _provider.findMovie(title, year: year);
  }

  Future<void> reload() {
    return _provider.reload();
  }
}

abstract class MovieProvider {
  Iterable<String> findByTitle(String query);

  Movie? findMovie(String title, {int? year});

  Future<void> reload();
}

class DefaultMovieProvider extends MovieProvider {
  final ClientRepository clientRepository;
  final movies = <int, Movie>{};
  final titles = <String>[];

  DefaultMovieProvider(this.clientRepository) {
    _load();
  }

  @override
  Future<void> reload() {
    return _load(ttl: Duration.zero);
  }

  Future<void> _load({Duration? ttl}) async {
    return clientRepository
        .movies(ttl: ttl)
        .then((view) {
          movies.clear();
          titles.clear();
          for (var movie in view.movies) {
            movies[movie.tmid] = movie;
            titles.add(movie.title);
          }
        })
        .onError((error, stackTrace) {
          Future.delayed(const Duration(minutes: 3), () => _load());
        });
  }

  @override
  Iterable<String> findByTitle(String query) {
    final result = <String>[];
    query = query.toLowerCase();
    result.addAll(titles.where((title) => title.toLowerCase().contains(query)));
    return result;
  }

  @override
  Movie? findMovie(String title, {int? year}) {
    title = title.toLowerCase();
    for (var m in movies.values) {
      // TODO slow search but should be ok
      if (m.title.toLowerCase() == title && (year == null || year == m.year)) {
        return m;
      }
    }
    return null;
  }
}
