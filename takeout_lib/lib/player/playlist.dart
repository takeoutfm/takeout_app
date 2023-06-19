// Copyright 2023 defsub
//
// This file is part of Takeout.
//
// Takeout is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

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

class PlaylistUpdate extends PlaylistState {
  PlaylistUpdate(super.spiff);
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

  void replace(
    String ref, {
    int index = 0,
    double position = 0.0,
    MediaType mediaType = MediaType.music,
    String? creator = '',
    String? title = '',
  }) {
    final body =
        patchReplace(ref, mediaType.name, creator: creator, title: title) +
            patchPosition(index, position);
    clientRepository.patch(body).then((result) {
      if (result.isModified) {
        final spiff = Spiff.fromJson(result.body);
        emit(PlaylistChange(spiff));
      } else {
        // emit as PlaylistChange for now
        emit(PlaylistChange(state.spiff));
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
