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

import 'favorite.dart';

abstract class FavoriteProvider {
  bool isFavoriteTrack(String etag);

  Stream<Favorite> get stream;

  Favorite get favorite;

  // Future<void> favoriteTrack(String etag);
  //
  // Future<void> unfavoriteTrack(String etag);
}

class DefaultFavoriteProvider implements FavoriteProvider {
  final FavoriteCubit _favoriteCubit;

  DefaultFavoriteProvider(FavoriteCubit favoriteCubit)
    : _favoriteCubit = favoriteCubit;

  @override
  bool isFavoriteTrack(String etag) =>
      _favoriteCubit.state.favorite.isFavoriteTrack(etag);

  @override
  Stream<Favorite> get stream => _favoriteCubit.stream.map((s) => s.favorite);

  @override
  Favorite get favorite => _favoriteCubit.state.favorite;

  // @override
  // Future<void> favoriteTrack(String etag) => _favoriteCubit.favoriteTrack(etag);
  //
  // @override
  // Future<void> unfavoriteTrack(String etag) =>
  //     _favoriteCubit.unfavoriteTrack(etag);
}
