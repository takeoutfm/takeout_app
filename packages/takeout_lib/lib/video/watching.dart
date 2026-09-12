// Copyright 2026 defsub
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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/video/track.dart';

part 'watching.g.dart';

@JsonSerializable()
class NowWatching {
  final VideoTrack? video;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool autoStart;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool autoSubtitles;
  final Duration? duration;
  final DateTime? started;
  final Offset? offset;
  final int? selectedAudioTrack;
  final int? selectedSubtitleTrack;

  NowWatching(
    this.video, {
    this.autoStart = false,
    this.autoSubtitles = false,
    this.duration,
    this.started,
    this.offset,
    this.selectedAudioTrack,
    this.selectedSubtitleTrack,
  });

  factory NowWatching.initial() => NowWatching(null);

  factory NowWatching.fromJson(Map<String, dynamic> json) =>
      _$NowWatchingFromJson(json);

  Map<String, dynamic> toJson() => _$NowWatchingToJson(this);

  NowWatching copyWith({
    Duration? duration,
    DateTime? started,
    Offset? offset,
    int? selectedAudioTrack,
    int? selectedSubtitleTrack,
  }) => NowWatching(
    video,
    autoStart: autoStart,
    autoSubtitles: autoSubtitles,
    duration: duration ?? this.duration,
    started: started ?? this.started,
    offset: offset ?? this.offset,
    selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
    selectedSubtitleTrack: selectedSubtitleTrack ?? this.selectedSubtitleTrack,
  );
}

sealed class NowWatchingState {
  final NowWatching nowWatching;

  NowWatchingState(this.nowWatching);
}

final class NowWatchingInit extends NowWatchingState {
  NowWatchingInit(super.nowWatching);
}

final class NowWatchingStart extends NowWatchingState {
  NowWatchingStart(super.nowWatching);
}

final class NowWatchingChange extends NowWatchingState {
  NowWatchingChange(super.nowWatching);
}

final class NowWatchingOffsetChange extends NowWatchingState {
  NowWatchingOffsetChange(super.nowWatching);
}

final class NowWatchingAudioTrackChange extends NowWatchingState {
  NowWatchingAudioTrackChange(super.nowWatching);
}

final class NowWatchingSubtitleTrackChange extends NowWatchingState {
  NowWatchingSubtitleTrackChange(super.nowWatching);
}

class NowWatchingCubit extends HydratedCubit<NowWatchingState> {
  NowWatchingCubit() : super(NowWatchingInit(NowWatching.initial()));

  void restore() {
    emit(NowWatchingChange(state.nowWatching));
  }

  /// add is called when videos are started/restarted
  void add(
    VideoTrack video, {
    bool autoStart = false,
    bool autoSubtitles = false,
    Offset? offset,
  }) => emit(
    NowWatchingChange(
      NowWatching(
        video,
        autoStart: autoStart,
        autoSubtitles: autoSubtitles,
        offset: offset,
      ),
    ),
  );

  void setAudioTrack(int index) {
    emit(
      NowWatchingAudioTrackChange(
        state.nowWatching.copyWith(selectedAudioTrack: index),
      ),
    );
  }

  void setSubtitleTrack(int index) {
    emit(
      NowWatchingSubtitleTrackChange(
        state.nowWatching.copyWith(selectedSubtitleTrack: index),
      ),
    );
  }

  void setOffset(Offset offset) {
    emit(NowWatchingOffsetChange(state.nowWatching.copyWith(offset: offset)));
  }

  @override
  NowWatchingState fromJson(Map<String, dynamic> json) {
    final state = NowWatching.fromJson(
      json['nowWatching'] as Map<String, dynamic>,
    );
    return NowWatchingStart(state);
  }

  @override
  Map<String, dynamic>? toJson(NowWatchingState state) => {
    'nowWatching': state.nowWatching.toJson(),
  };
}
