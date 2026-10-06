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
import 'package:takeout_lib/client/repository.dart';

// import 'model.dart';
// import 'repository.dart';

part 'favorite.g.dart';

@JsonSerializable()
class Favorite {
  final Set<String> artists;
  final Set<String> movies;
  final Set<int> shows;
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
    Set<String>? artists,
    Set<String>? movies,
    Set<int>? shows,
    Set<String>? tracks,
  }) => Favorite(
    artists: artists ?? this.artists,
    movies: movies ?? this.movies,
    shows: shows ?? this.shows,
    tracks: tracks ?? this.tracks,
  );

  bool isFavoriteTrack(String etag) => tracks.contains(etag);

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
                artists: view.artists.map((a) => a.arid).nonNulls.toSet(),
                movies: view.movies.map((m) => m.imid).toSet(),
                shows: view.shows.map((m) => m.tvid).toSet(),
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
        .then((_) => emit(FavoriteTrackChange(state.favorite.addTrack(etag))));
  }

  Future<void> unfavoriteTrack(String etag) {
    return clientRepository
        .unfavoriteTrack(etag)
        .timeout(_timeout)
        .then(
          (_) => emit(FavoriteTrackChange(state.favorite.removeTrack(etag))),
        );
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
