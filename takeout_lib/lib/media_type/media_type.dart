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

enum PodcastType { all, recent, subscribed }

enum VideoType {
  all,
  recent,
  added,
  recommended,
}

enum MusicType { recent, added }

@JsonSerializable()
class MediaTypeState {
  final MediaType mediaType;
  final PodcastType podcastType;
  final VideoType videoType;
  final MusicType musicType;

  factory MediaTypeState.initial() => MediaTypeState(MediaType.music,
      podcastType: PodcastType.recent,
      videoType: VideoType.added,
      musicType: MusicType.added);

  // provide defaults for older state w/o all types
  MediaTypeState(this.mediaType,
      {this.podcastType = PodcastType.recent,
      this.videoType = VideoType.added,
      this.musicType = MusicType.added});

  bool isMusic() {
    return mediaType == MediaType.music;
  }

  bool isPodcast() {
    return mediaType == MediaType.podcast;
  }

  bool isVideo() {
    return mediaType == MediaType.video;
  }

  MediaTypeState copyWith({
    MediaType? mediaType,
    PodcastType? podcastType,
    VideoType? videoType,
    MusicType? musicType,
  }) =>
      MediaTypeState(mediaType ?? this.mediaType,
          podcastType: podcastType ?? this.podcastType,
          videoType: videoType ?? this.videoType,
          musicType: musicType ?? this.musicType);

  factory MediaTypeState.fromJson(Map<String, dynamic> json) =>
      _$MediaTypeStateFromJson(json);

  Map<String, dynamic> toJson() => _$MediaTypeStateToJson(this);
}

class MediaTypeCubit extends HydratedCubit<MediaTypeState> {
  MediaTypeCubit() : super(MediaTypeState.initial());

  // music -> video -> podcast
  void next() {
    switch (state.mediaType) {
      case MediaType.music:
        emit(state.copyWith(mediaType: MediaType.video));
      case MediaType.video:
        emit(state.copyWith(mediaType: MediaType.podcast));
      case MediaType.podcast:
        emit(state.copyWith(mediaType: MediaType.music));
      default:
        emit(state.copyWith(mediaType: MediaType.music));
    }
  }

  // music <- video <- podcast
  void previous() {
    switch (state.mediaType) {
      case MediaType.music:
        emit(state.copyWith(mediaType: MediaType.podcast));
      case MediaType.video:
        emit(state.copyWith(mediaType: MediaType.music));
      case MediaType.podcast:
        emit(state.copyWith(mediaType: MediaType.video));
      default:
        emit(state.copyWith(mediaType: MediaType.music));
    }
  }

  // all -> recent -> subscribed
  void nextPodcastType() {
    switch (state.podcastType) {
      case PodcastType.all:
        emit(state.copyWith(podcastType: PodcastType.recent));
      case PodcastType.recent:
        emit(state.copyWith(podcastType: PodcastType.subscribed));
      case PodcastType.subscribed:
        emit(state.copyWith(podcastType: PodcastType.all));
      default:
        emit(state.copyWith(podcastType: PodcastType.recent));
    }
  }

  // all -> recent -> added -> recommended
  void nextVideoType() {
    switch (state.videoType) {
      case VideoType.all:
        emit(state.copyWith(videoType: VideoType.recent));
      case VideoType.recent:
        emit(state.copyWith(videoType: VideoType.added));
      case VideoType.added:
        emit(state.copyWith(videoType: VideoType.recommended));
      case VideoType.recommended:
        emit(state.copyWith(videoType: VideoType.all));
      default:
        emit(state.copyWith(videoType: VideoType.added));
    }
  }

  // recent -> added
  void nextMusicType() {
    switch (state.musicType) {
      case MusicType.recent:
        emit(state.copyWith(musicType: MusicType.added));
      case MusicType.added:
        emit(state.copyWith(musicType: MusicType.recent));
      default:
        emit(state.copyWith(musicType: MusicType.added));
    }
  }

  void select(MediaType mediaType,
      {PodcastType? podcastType, VideoType? videoType, MusicType? musicType}) {
    emit(state.copyWith(
        mediaType: mediaType,
        podcastType: podcastType,
        videoType: videoType,
        musicType: musicType));
  }

  @override
  MediaTypeState? fromJson(Map<String, dynamic> json) =>
      MediaTypeState.fromJson(json['mediaType'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(MediaTypeState state) =>
      {'mediaType': state.toJson()};
}
