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
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/patch.dart';
import 'package:takeout_lib/spiff/model.dart';

class PlaylistState {
  final Spiff spiff;

  PlaylistState(this.spiff);

  factory PlaylistState.initial() => PlaylistState(Spiff.empty());
}

class PlaylistLoad extends PlaylistState {
  PlaylistLoad(super.spiff);
}

class PlaylistChange extends PlaylistState {
  PlaylistChange(super.spiff);
}

class PlaylistSync extends PlaylistState {
  PlaylistSync(super.spiff);
}

class PlaylistCubit extends Cubit<PlaylistState> {
  final ClientRepository clientRepository;

  PlaylistCubit(this.clientRepository) : super(PlaylistState.initial()) {
    load();
  }

  void load({Duration? ttl}) {
    clientRepository.playlist(ttl: ttl).then((spiff) {
      emit(PlaylistLoad(spiff));
    }).onError((error, stackTrace) {});
  }

  void reload() {
    load(ttl: Duration.zero);
  }

  void sync() {
    clientRepository.playlist(ttl: Duration.zero).then((spiff) {
      emit(PlaylistSync(spiff));
    }).onError((error, stackTrace) {});
  }

  void replace(
    String ref, {
    int index = 0,
    double position = 0.0,
    MediaType mediaType = MediaType.music,
    String? creator = '',
    String? title = '',
    bool shuffle = false,
  }) {
    clientRepository
        .replace(ref,
            index: index,
            position: position,
            mediaType: mediaType,
            creator: creator,
            title: title)
        .then((spiff) {
      if (spiff != null) {
        if (shuffle) {
          spiff = spiff.shuffle();
        }
        emit(PlaylistChange(spiff));
      } else {
        // unchanged
        if (state.spiff.isEmpty) {
          // no local state, force a sync
          sync();
        } else {
          // emit as PlaylistChange for now
          emit(PlaylistChange(state.spiff));
        }
      }
    }).onError((error, stackTrace) {
      // TODO
    });
  }

  void update({int index = 0, double position = 0.0}) {
    final body = patchPosition(index, position);
    clientRepository.patch(body).then((result) {
      // TODO
    }).onError((error, stackTrace) {
      // TODO
    });
  }
}
