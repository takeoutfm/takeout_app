// Copyright 2023 defsub
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

import 'package:bloc/bloc.dart';
import 'package:takeout_lib/client/repository.dart';

class IndexState {
  final bool movies;
  final bool music;
  final bool podcasts;
  final bool playlists;
  final bool shows;

  IndexState(
      {required this.movies,
      required this.music,
      required this.podcasts,
      required this.playlists,
      required this.shows});

  factory IndexState.initial() => IndexState(
      movies: false,
      music: false,
      podcasts: false,
      playlists: false,
      shows: false);
}

class IndexCubit extends Cubit<IndexState> {
  final ClientRepository clientRepository;

  IndexCubit(this.clientRepository) : super(IndexState.initial()) {
    _load();
  }

  void _load({Duration? ttl}) {
    clientRepository.index(ttl: ttl).then((view) {
      emit(IndexState(
          movies: view.hasMovies,
          music: view.hasMusic,
          podcasts: view.hasPodcasts,
          playlists: view.hasPlaylists,
          shows: view.hasShows));
    }).onError((error, stackTrace) {
      Future.delayed(const Duration(minutes: 3), () => _load());
    });
  }

  void reload() {
    _load(ttl: Duration.zero);
  }
}
