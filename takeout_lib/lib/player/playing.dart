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

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playing.g.dart';

@JsonSerializable()
class NowPlayingState {
  final Spiff spiff;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool autoPlay;
  final bool autoCache;
  final List<DateTime?>? started;
  final List<DateTime?>? listened;

  NowPlayingState(this.spiff,
      {this.autoPlay = false,
      this.autoCache = false,
      this.started,
      this.listened});

  bool listenedTo(int index) {
    return listened?[index] != null;
  }

  DateTime? listenedAt(int index) {
    return listened?[index];
  }

  DateTime? startedAt(int index) {
    return started?[index];
  }

  factory NowPlayingState.initial() => NowPlayingState(Spiff.empty());

  factory NowPlayingState.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingStateFromJson(json);

  Map<String, dynamic> toJson() => _$NowPlayingStateToJson(this);
}

class NowPlayingChange extends NowPlayingState {
  NowPlayingChange(super.spiff, {super.autoPlay, super.autoCache});
}

class NowPlayingIndexChange extends NowPlayingState {
  NowPlayingIndexChange(super.spiff, {super.started});
}

class NowPlayingListenChange extends NowPlayingState {
  NowPlayingListenChange(super.spiff, {super.listened});
}

class NowPlayingCubit extends HydratedCubit<NowPlayingState> {
  NowPlayingCubit() : super(NowPlayingState.initial());

  void add(Spiff spiff, {bool? autoPlay, bool? autoCache}) =>
      emit(NowPlayingChange(spiff,
          autoPlay: autoPlay ?? false, autoCache: autoCache ?? false));

  void index(int index) {
    final started =
        state.started ?? List<DateTime?>.filled(state.spiff.length, null);
    started[index] = DateTime.now();
    emit(NowPlayingIndexChange(state.spiff.copyWith(index: index),
        started: started));
  }

  void listened(int index, DateTime listenedAt) {
    final listened =
        state.listened ?? List<DateTime?>.filled(state.spiff.length, null);
    listened[index] = listenedAt;
    emit(NowPlayingListenChange(state.spiff.copyWith(index: index),
        listened: listened));
  }

  @override
  NowPlayingState fromJson(Map<String, dynamic> json) =>
      NowPlayingState.fromJson(json['nowPlaying'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(NowPlayingState state) =>
      {'nowPlaying': state.toJson()};
}
