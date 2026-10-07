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
import 'provider.dart';

class FavoriteRepository {
  FavoriteProvider? _provider;

  FavoriteRepository({FavoriteProvider? provider}) : _provider = provider;

  void init(FavoriteCubit cubit) {
    _provider = DefaultFavoriteProvider(cubit);
  }

  bool isFavoriteTrack(String etag) =>
      _provider?.isFavoriteTrack(etag) ?? false;

  Stream<Favorite> get stream {
    final provider = _provider;
    if (provider == null) {
      throw StateError('no provider for stream');
    }
    return provider.stream;
  }

  Favorite get favorite {
    final provider = _provider;
    if (provider == null) {
      throw StateError('no provider for favorite');
    }
    return provider.favorite;
  }

  // Future<void> favoriteTrack(String etag) {
  //   final provider = _provider;
  //   if (provider == null) {
  //     throw StateError('no provider for favoriteTrack');
  //   }
  //   return provider.favoriteTrack(etag);
  // }
  //
  // Future<void> unfavoriteTrack(String etag) {
  //   final provider = _provider;
  //   if (provider == null) {
  //     throw StateError('no provider for unfavoriteTrack');
  //   }
  //   return provider.unfavoriteTrack(etag);
  // }
}
