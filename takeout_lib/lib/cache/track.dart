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

import 'dart:io';

import 'package:bloc/bloc.dart';

import 'file.dart';
import 'track_repository.dart';

class TrackCacheState extends FileCacheState {
  TrackCacheState(super.keys);

  factory TrackCacheState.empty() {
    return TrackCacheState(<String>{});
  }
}

class TrackCacheCubit extends Cubit<TrackCacheState> {
  final TrackCacheRepository repository;

  TrackCacheCubit(this.repository) : super(TrackCacheState.empty()) {
    _emitState();
  }

  Future<void> _emitState() async {
    final keys = await repository.keys();
    emit(TrackCacheState(Set<String>.from(keys)));
  }

  void add(TrackIdentifier id, File file) {
    repository.put(id, file).whenComplete(() => _emitState());
  }

  void remove(TrackIdentifier id) {
    repository.remove(id).whenComplete(() => _emitState());
  }

  void removeIds(Iterable<TrackIdentifier> ids) {
    Future.forEach<TrackIdentifier>(ids, (id) => repository.remove(id))
        .whenComplete(() => _emitState());
  }

  void removeAll() {
    repository.removeAll().whenComplete(() => _emitState());
  }

  void retain(Iterable<TrackIdentifier> ids) {
    repository.retain(ids).whenComplete(() => _emitState());
  }
}
