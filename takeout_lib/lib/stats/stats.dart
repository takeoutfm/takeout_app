// Copyright 2024 defsub
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

part 'stats.g.dart';

enum StatsType { artist, release, track }

enum IntervalType {
  recent,
  today,
  yesterday,
  week,
  lastweek,
  month,
  lastmonth,
  year,
  lastyear,
  all;

  static final _names = IntervalType.values.asNameMap();

  static IntervalType of(String name) {
    final value = _names[name];
    return value ?? (throw ArgumentError());
  }
}

@JsonSerializable()
class StatsState {
  final StatsType type;
  final IntervalType interval;

  factory StatsState.initial() =>
      StatsState(StatsType.artist, IntervalType.recent);

  StatsState(this.type, this.interval);

  StatsState copyWith({
    StatsType? type,
    IntervalType? interval,
  }) =>
      StatsState(type ?? this.type, interval ?? this.interval);

  factory StatsState.fromJson(Map<String, dynamic> json) =>
      _$StatsStateFromJson(json);

  Map<String, dynamic> toJson() => _$StatsStateToJson(this);
}

class StatsCubit extends HydratedCubit<StatsState> {
  StatsCubit() : super(StatsState.initial());

  void type(StatsType type) {
    emit(state.copyWith(type: type));
  }

  void interval(IntervalType interval) {
    emit(state.copyWith(interval: interval));
  }

  @override
  StatsState? fromJson(Map<String, dynamic> json) =>
      StatsState.fromJson(json['stats'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(StatsState state) => {'stats': state.toJson()};
}
