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

import 'file_provider.dart';
import 'file_repository.dart';

class FileCacheState {
  final Set<String> keys;

  FileCacheState(this.keys);

  factory FileCacheState.empty() {
    return FileCacheState(<String>{});
  }

  FileCacheState copyWith({Set<String>? keys}) =>
      FileCacheState(keys ?? this.keys);

  bool contains(FileIdentifier id) {
    return keys.contains(id.key);
  }

  bool containsAll(Iterable<FileIdentifier> ids) {
    final set = <String>{};
    for (var e in ids) {
      set.add(e.key);
    }
    return keys.containsAll(set);
  }

  bool get isNotEmpty => keys.isNotEmpty;

  bool get isEmpty => keys.isEmpty;

  int count(Iterable<FileIdentifier> ids) {
    var count = 0;
    for (var e in ids) {
      if (contains(e)) {
        count++;
      }
    }
    return count;
  }
}

class FileCacheCubit extends Cubit<FileCacheState> {
  final FileCacheRepository repository;

  FileCacheCubit(this.repository) : super(FileCacheState.empty()) {
    _emitState();
  }

  Future<void> _emitState() async {
    final keys = await repository.keys();
    emit(FileCacheState(Set<String>.from(keys)));
  }

  void add(FileIdentifier id, File file) {
    repository.put(id, file).whenComplete(() => _emitState());
  }

  void remove(FileIdentifier id) {
    repository.remove(id).whenComplete(() => _emitState());
  }

  void retain(Iterable<FileIdentifier> ids) {
    repository.retain(ids).whenComplete(() => _emitState());
  }
}
