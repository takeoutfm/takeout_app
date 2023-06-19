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
import 'package:json_annotation/json_annotation.dart';

part 'media_type.g.dart';

enum MediaType {
  music,
  video,
  podcast,
  stream;

  static final _names = MediaType.values.asNameMap();

  static MediaType of(String name) {
    final value = _names[name];
    return value ?? (throw ArgumentError());
  }
}

@JsonSerializable()
class MediaTypeState {
  final MediaType mediaType;

  MediaTypeState(this.mediaType);

  factory MediaTypeState.fromJson(Map<String, dynamic> json) =>
      _$MediaTypeStateFromJson(json);

  Map<String, dynamic> toJson() => _$MediaTypeStateToJson(this);
}

class MediaTypeCubit extends HydratedCubit<MediaTypeState> {
  MediaTypeCubit() : super(MediaTypeState(MediaType.music));

  // music -> video -> podcast
  void next() {
    switch (state.mediaType) {
      case MediaType.music:
        emit(MediaTypeState(MediaType.video));
      case MediaType.video:
        emit(MediaTypeState(MediaType.podcast));
      case MediaType.podcast:
        emit(MediaTypeState(MediaType.music));
      default:
        emit(MediaTypeState(MediaType.music));
    }
  }

  // music <- video <- podcast
  void previous() {
    switch (state.mediaType) {
      case MediaType.music:
        emit(MediaTypeState(MediaType.podcast));
      case MediaType.video:
        emit(MediaTypeState(MediaType.music));
      case MediaType.podcast:
        emit(MediaTypeState(MediaType.video));
      default:
        emit(MediaTypeState(MediaType.music));
    }
  }

  void select(MediaType mediaType) {
    emit(MediaTypeState(mediaType));
  }

  @override
  MediaTypeState? fromJson(Map<String, dynamic> json) =>
      MediaTypeState.fromJson(json['mediaType'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(MediaTypeState state) =>
      {'mediaType': state.toJson()};
}
