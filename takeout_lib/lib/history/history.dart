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
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/spiff/model.dart';

import 'model.dart';
import 'repository.dart';

class HistoryState {
  final History history;

  HistoryState(this.history);
}

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;

  HistoryCubit(this.repository) : super(HistoryState(History.empty())) {
    _load();
  }

  void _load() {
    repository
        .get()
        .then((history) => emit(HistoryState(history.unmodifiableCopy())));
  }

  void add({String? search, Spiff? spiff, MediaTrack? track, DateTime? dateTime}) {
    repository
        .add(search: search, spiff: spiff, track: track, dateTime: dateTime)
        .then((history) => emit(HistoryState(history.unmodifiableCopy())));
  }

  void remove() {
    repository
        .remove()
        .then((history) => emit(HistoryState(history.unmodifiableCopy())));
  }
}
