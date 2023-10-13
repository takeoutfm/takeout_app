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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/client/repository.dart';

class SubscribedState {
  final List<Series> series;

  SubscribedState({required this.series});

  factory SubscribedState.initial() => SubscribedState(series: []);

  bool isSubscribed(Series s) {
    for (var i in series) {
      if (i.sid == s.sid) {
        return true;
      }
    }
    return false;
  }
}

class SubscribedCubit extends Cubit<SubscribedState> {
  final ClientRepository clientRepository;

  SubscribedCubit(this.clientRepository) : super(SubscribedState.initial()) {
    _load();
  }

  void _load({Duration? ttl}) {
    clientRepository.podcastsSubscribed(ttl: ttl).then((view) {
      emit(SubscribedState(series: view.series));
    }).onError((error, stackTrace) {
      Future.delayed(const Duration(minutes: 3), () => _load());
    });
  }

  void reload() {
    _load(ttl: Duration.zero);
  }

  void subscribe(Series series) {
    clientRepository.seriesSubscribe(series.id).then((_) => reload());
  }

  void unsubscribe(Series series) {
    clientRepository.seriesUnsubscribe(series.id).then((_) => reload());
  }
}
