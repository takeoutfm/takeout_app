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
import 'package:json_annotation/json_annotation.dart';
import 'package:takeout_lib/spiff/model.dart';

import 'repeat.dart';

part 'playing.g.dart';

@JsonSerializable()
class NowPlaying {
  final Spiff spiff;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool autoPlay;
  final bool autoCache;
  final List<DateTime?>? started;
  final List<DateTime?>? listened;
  final RepeatMode? repeat;

  NowPlaying(this.spiff,
      {this.repeat,
      this.autoPlay = false,
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

  factory NowPlaying.initial() =>
      NowPlaying(Spiff.empty(), repeat: RepeatMode.none);

  factory NowPlaying.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingFromJson(json);

  Map<String, dynamic> toJson() => _$NowPlayingToJson(this);

  NowPlaying copyWith(
          {Spiff? spiff,
          RepeatMode? repeat,
          bool? autoPlay,
          bool? autoCache,
          List<DateTime?>? started,
          List<DateTime?>? listened}) =>
      NowPlaying(spiff ?? this.spiff,
          repeat: repeat ?? this.repeat,
          autoPlay: autoPlay ?? this.autoPlay,
          autoCache: autoCache ?? this.autoCache,
          started: started ?? this.started,
          listened: listened ?? this.listened);
}

@JsonSerializable()
class NowPlayingState {
  final NowPlaying nowPlaying;

  NowPlayingState(this.nowPlaying);

  factory NowPlayingState.initial() => NowPlayingState(NowPlaying.initial());

  factory NowPlayingState.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingStateFromJson(json);

  Map<String, dynamic> toJson() => _$NowPlayingStateToJson(this);
}

class NowPlayingInit extends NowPlayingState {
  NowPlayingInit(super.nowPlaying);
}

class NowPlayingChange extends NowPlayingState {
  NowPlayingChange(super.nowPlaying);
}

class NowPlayingIndexChange extends NowPlayingState {
  NowPlayingIndexChange(super.nowPlaying);
}

class NowPlayingListenChange extends NowPlayingState {
  NowPlayingListenChange(super.nowPlaying);
}

class NowPlayingRepeatChange extends NowPlayingState {
  NowPlayingRepeatChange(super.nowPlaying);
}

class NowPlayingCubit extends HydratedCubit<NowPlayingState> {
  NowPlayingCubit() : super(NowPlayingState.initial());

  void restore() {
    emit(NowPlayingChange(state.nowPlaying));
  }

  void add(Spiff spiff,
          {bool? autoPlay, bool? autoCache, RepeatMode? repeat}) =>
      emit(NowPlayingChange(state.nowPlaying.copyWith(
        spiff: spiff,
        // clear started & listen state
        started: null,
        listened: null,
        autoCache: autoCache,
        autoPlay: autoPlay,
        repeat: repeat,
      )));

  void index(int index) {
    final started = state.nowPlaying.started ??
        List<DateTime?>.filled(state.nowPlaying.spiff.length, null);
    started[index] = DateTime.now();
    emit(NowPlayingIndexChange(state.nowPlaying.copyWith(
      spiff: state.nowPlaying.spiff.copyWith(index: index),
      started: started,
    )));
  }

  void listened(int index, DateTime listenedAt) {
    final listened = state.nowPlaying.listened ??
        List<DateTime?>.filled(state.nowPlaying.spiff.length, null);
    listened[index] = listenedAt;
    emit(NowPlayingListenChange(state.nowPlaying.copyWith(
      spiff: state.nowPlaying.spiff.copyWith(index: index),
      listened: listened,
    )));
  }

  void repeatMode(RepeatMode repeat) {
    emit(NowPlayingRepeatChange(state.nowPlaying.copyWith(repeat: repeat)));
  }

  @override
  NowPlayingState fromJson(Map<String, dynamic> json) {
    final state =
        NowPlayingState.fromJson(json['nowPlaying'] as Map<String, dynamic>);
    return NowPlayingInit(state.nowPlaying);
  }

  @override
  Map<String, dynamic>? toJson(NowPlayingState state) =>
      {'nowPlaying': state.toJson()};
}
