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

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'playing.g.dart';

@JsonSerializable()
class NowPlayingState {
  final Spiff spiff;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool autoplay;

  NowPlayingState(this.spiff, {bool? autoplay})
      : autoplay = autoplay ?? false;

  factory NowPlayingState.initial() => NowPlayingState(Spiff.empty());

  factory NowPlayingState.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingStateFromJson(json);

  Map<String, dynamic> toJson() => _$NowPlayingStateToJson(this);
}

class NowPlayingChange extends NowPlayingState {
  NowPlayingChange(super.spiff, {super.autoplay});
}

class NowPlayingIndexChange extends NowPlayingState {
  NowPlayingIndexChange(super.spiff);
}

class NowPlayingCubit extends HydratedCubit<NowPlayingState> {
  NowPlayingCubit() : super(NowPlayingState.initial());

  void add(Spiff spiff, {bool? autoplay}) =>
      emit(NowPlayingChange(spiff, autoplay: autoplay));

  void index(int index) =>
      emit(NowPlayingIndexChange(state.spiff.copyWith(index: index)));

  @override
  NowPlayingState fromJson(Map<String, dynamic> json) =>
      NowPlayingState.fromJson(json['nowPlaying'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(NowPlayingState state) =>
      {'nowPlaying': state.toJson()};
}
