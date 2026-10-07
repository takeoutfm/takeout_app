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

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/client/repository.dart';

// import 'model.dart';
// import 'repository.dart';

part 'favorite.g.dart';

@JsonSerializable()
class Favorite {
  final Map<String, Artist> artists;
  final Map<String, Movie> movies;
  final Map<int, TVSeries> shows;
  final Set<String> tracks;

  Favorite({
    required this.artists,
    required this.movies,
    required this.shows,
    required this.tracks,
  });

  factory Favorite.initial() =>
      Favorite(artists: {}, movies: {}, shows: {}, tracks: {});

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  Favorite copyWith({
    Map<String, Artist>? artists,
    Map<String, Movie>? movies,
    Map<int, TVSeries>? shows,
    Set<String>? tracks,
  }) => Favorite(
    artists: artists ?? this.artists,
    movies: movies ?? this.movies,
    shows: shows ?? this.shows,
    tracks: tracks ?? this.tracks,
  );

  bool isFavoriteTrack(String etag) => tracks.contains(etag);

  bool isFavoriteArtist(Artist artist) => artists.containsKey(artist.arid);

  bool isFavoriteMovie(Movie movie) => movies.containsKey(movie.imid);

  bool isFavoriteTVSeries(TVSeries series) => shows.containsKey(series.tvid);

  Favorite addTrack(String etag) {
    final set = Set<String>.from(tracks);
    set.add(etag);
    return copyWith(tracks: set);
  }

  Favorite removeTrack(String etag) {
    final set = Set<String>.from(tracks);
    set.remove(etag);
    return copyWith(tracks: set);
  }

  Iterable<Artist> sortedArtists() {
    final list = List<Artist>.from(artists.values);
    list.sort((a, b) => a.sortName.compareTo(b.sortName));
    return list;
  }

  Iterable<Movie> sortedMovies() {
    final list = List<Movie>.from(movies.values);
    list.sort((a, b) => a.sortTitle.compareTo(b.sortTitle));
    return list;
  }
}

sealed class FavoriteState {
  final Favorite favorite;

  FavoriteState(this.favorite);
}

final class FavoriteInit extends FavoriteState {
  FavoriteInit(super.favorite);
}

final class FavoriteStart extends FavoriteState {
  FavoriteStart(super.favorite);
}

final class FavoriteLoad extends FavoriteState {
  FavoriteLoad(super.favorite);
}

final class FavoriteTrackChange extends FavoriteState {
  FavoriteTrackChange(super.favorite);
}

final class FavoriteArtistFailed extends FavoriteState {
  FavoriteArtistFailed(super.favorite);
}

final class FavoriteMovieFailed extends FavoriteState {
  FavoriteMovieFailed(super.favorite);
}

final class FavoriteTVSeriesFailed extends FavoriteState {
  FavoriteTVSeriesFailed(super.favorite);
}

class FavoriteCubit extends HydratedCubit<FavoriteState> {
  final ClientRepository clientRepository;
  final Duration _timeout;

  FavoriteCubit(this.clientRepository, {Duration? timeout})
    : _timeout = timeout ?? const Duration(seconds: 5),
      super(FavoriteInit(Favorite.initial())) {
    _load();
  }

  Future<void> _load({Duration? ttl}) async {
    await clientRepository
        .favorite(ttl: ttl)
        .then((view) {
          emit(
            FavoriteLoad(
              Favorite(
                artists: {for (final a in view.artists) ?a.arid: a},
                movies: {for (final m in view.movies) m.imid: m},
                shows: {for (final s in view.shows) s.tvid: s},
                tracks: view.tracks.map((t) => t.etag).toSet(),
              ),
            ),
          );
        })
        .onError((error, stackTrace) {
          Future.delayed(const Duration(minutes: 3), () => _load());
        });
  }

  Future<void> reload() => _load(ttl: Duration.zero);

  Future<void> toggleFavoriteTrack(String etag) {
    final isFavorite = state.favorite.isFavoriteTrack(etag);
    return isFavorite ? unfavoriteTrack(etag) : favoriteTrack(etag);
  }

  Future<void> favoriteTrack(String etag) {
    return clientRepository
        .favoriteTrack(etag)
        .timeout(_timeout)
        .then((_) => isClosed ? null : _load());
  }

  Future<void> unfavoriteTrack(String etag) {
    return clientRepository
        .unfavoriteTrack(etag)
        .timeout(_timeout)
        .then((_) => isClosed ? null : _load());
  }

  Future<void> toggleFavoriteArtist(Artist artist) {
    final isFavorite = state.favorite.isFavoriteArtist(artist);
    return isFavorite ? unfavoriteArtist(artist) : favoriteArtist(artist);
  }

  Future<void> favoriteArtist(Artist artist) {
    return clientRepository
        .favoriteArtist(artist)
        .timeout(_timeout)
        .then((_) {
          if (isClosed) return null;
          return _load(ttl: .zero);
        })
        .catchError((Object e) {
          if (!isClosed) emit(FavoriteArtistFailed(state.favorite));
        });
  }

  Future<void> unfavoriteArtist(Artist artist) {
    return clientRepository
        .unfavoriteArtist(artist)
        .timeout(_timeout)
        .then((_) {
          if (isClosed) return null;
          return _load(ttl: .zero);
        })
        .catchError((Object e) {
          if (!isClosed) emit(FavoriteArtistFailed(state.favorite));
        });
  }

  Future<void> toggleFavoriteMovie(Movie movie) {
    final isFavorite = state.favorite.isFavoriteMovie(movie);
    return isFavorite ? unfavoriteMovie(movie) : favoriteMovie(movie);
  }

  Future<void> favoriteMovie(Movie movie) {
    return clientRepository
        .favoriteMovie(movie)
        .timeout(_timeout)
        .then((_) {
          if (isClosed) return null;
          return _load(ttl: .zero);
        })
        .catchError((Object e) {
          if (!isClosed) emit(FavoriteMovieFailed(state.favorite));
        });
  }

  Future<void> unfavoriteMovie(Movie movie) {
    return clientRepository
        .unfavoriteMovie(movie)
        .timeout(_timeout)
        .then((_) {
          if (isClosed) return null;
          return _load(ttl: .zero);
        })
        .catchError((Object e) {
          if (!isClosed) emit(FavoriteMovieFailed(state.favorite));
        });
  }

  Future<void> toggleFavoriteTVSeries(TVSeries series) {
    final isFavorite = state.favorite.isFavoriteTVSeries(series);
    return isFavorite ? unfavoriteTVSeries(series) : favoriteTVSeries(series);
  }

  Future<void> favoriteTVSeries(TVSeries series) {
    return clientRepository
        .favoriteTVSeries(series)
        .timeout(_timeout)
        .then((_) {
          if (isClosed) return null;
          return _load(ttl: .zero);
        })
        .catchError((Object e) {
          if (!isClosed) emit(FavoriteTVSeriesFailed(state.favorite));
        });
  }

  Future<void> unfavoriteTVSeries(TVSeries series) {
    return clientRepository
        .unfavoriteTVSeries(series)
        .timeout(_timeout)
        .then((_) {
          if (isClosed) return null;
          return _load(ttl: .zero);
        })
        .catchError((Object e) {
          if (!isClosed) emit(FavoriteTVSeriesFailed(state.favorite));
        });
  }

  @override
  FavoriteState fromJson(Map<String, dynamic> json) {
    final state = Favorite.fromJson(json['favorite'] as Map<String, dynamic>);
    return FavoriteStart(state);
  }

  @override
  Map<String, dynamic>? toJson(FavoriteState state) => {
    'favorite': state.favorite.toJson(),
  };
}
