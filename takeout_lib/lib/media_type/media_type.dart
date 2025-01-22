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

part 'media_type.g.dart';

enum MediaType {
  music,
  film,
  tv,
  podcast,
  stream;

  static final _names = MediaType.values.asNameMap();

  static MediaType of(String name) {
    final value = _names[name];
    return value ?? (throw ArgumentError());
  }
}

enum PodcastType { all, recent, subscribed }

enum FilmType {
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
  final FilmType filmType;
  final MusicType musicType;

  factory MediaTypeState.initial() => MediaTypeState(MediaType.music,
      podcastType: PodcastType.recent,
      filmType: FilmType.added,
      musicType: MusicType.added);

  // provide defaults for older state w/o all types
  MediaTypeState(this.mediaType,
      {this.podcastType = PodcastType.recent,
      this.filmType = FilmType.added,
      this.musicType = MusicType.added});

  bool isMusic() {
    return mediaType == MediaType.music;
  }

  bool isPodcast() {
    return mediaType == MediaType.podcast;
  }

  bool isFilm() {
    return mediaType == MediaType.film;
  }

  bool isTV() {
    return mediaType == MediaType.tv;
  }

  MediaTypeState copyWith({
    MediaType? mediaType,
    PodcastType? podcastType,
    FilmType? filmType,
    MusicType? musicType,
  }) =>
      MediaTypeState(mediaType ?? this.mediaType,
          podcastType: podcastType ?? this.podcastType,
          filmType: filmType ?? this.filmType,
          musicType: musicType ?? this.musicType);

  factory MediaTypeState.fromJson(Map<String, dynamic> json) =>
      _$MediaTypeStateFromJson(json);

  Map<String, dynamic> toJson() => _$MediaTypeStateToJson(this);
}

class MediaTypeCubit extends HydratedCubit<MediaTypeState> {
  MediaTypeCubit() : super(MediaTypeState.initial());

  // music -> film -> tv -> podcast
  void next() {
    switch (state.mediaType) {
      case MediaType.music:
        emit(state.copyWith(mediaType: MediaType.film));
      case MediaType.film:
        emit(state.copyWith(mediaType: MediaType.tv));
      case MediaType.tv:
        emit(state.copyWith(mediaType: MediaType.podcast));
      case MediaType.podcast:
        emit(state.copyWith(mediaType: MediaType.music));
      default:
        emit(state.copyWith(mediaType: MediaType.music));
    }
  }

  // music <- film <- tv <- podcast
  void previous() {
    switch (state.mediaType) {
      case MediaType.music:
        emit(state.copyWith(mediaType: MediaType.podcast));
      case MediaType.film:
        emit(state.copyWith(mediaType: MediaType.music));
      case MediaType.tv:
        emit(state.copyWith(mediaType: MediaType.film));
      case MediaType.podcast:
        emit(state.copyWith(mediaType: MediaType.tv));
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
    }
  }

  // all -> recent -> added -> recommended
  void nextFilmType() {
    switch (state.filmType) {
      case FilmType.all:
        emit(state.copyWith(filmType: FilmType.recent));
      case FilmType.recent:
        emit(state.copyWith(filmType: FilmType.added));
      case FilmType.added:
        emit(state.copyWith(filmType: FilmType.recommended));
      case FilmType.recommended:
        emit(state.copyWith(filmType: FilmType.all));
    }
  }

  // recent -> added
  void nextMusicType() {
    switch (state.musicType) {
      case MusicType.recent:
        emit(state.copyWith(musicType: MusicType.added));
      case MusicType.added:
        emit(state.copyWith(musicType: MusicType.recent));
    }
  }

  void select(MediaType mediaType,
      {PodcastType? podcastType, FilmType? filmType, MusicType? musicType}) {
    emit(state.copyWith(
        mediaType: mediaType,
        podcastType: podcastType,
        filmType: filmType,
        musicType: musicType));
  }

  @override
  MediaTypeState? fromJson(Map<String, dynamic> json) =>
      MediaTypeState.fromJson(json['mediaType'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(MediaTypeState state) =>
      {'mediaType': state.toJson()};
}
