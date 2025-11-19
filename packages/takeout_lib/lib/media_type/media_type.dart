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

enum FilmType { all, recent, added, recommended }

enum MusicType { recent, added }

@JsonSerializable()
class MediaTypeState {
  final MediaType mediaType;
  final PodcastType podcastType;
  final FilmType filmType;
  final MusicType musicType;

  factory MediaTypeState.initial() => MediaTypeState(
    MediaType.music,
    podcastType: .recent,
    filmType: .added,
    musicType: .added,
  );

  // provide defaults for older state w/o all types
  MediaTypeState(
    this.mediaType, {
    this.podcastType = .recent,
    this.filmType = .added,
    this.musicType = .added,
  });

  bool isMusic() {
    return mediaType == .music;
  }

  bool isPodcast() {
    return mediaType == .podcast;
  }

  bool isFilm() {
    return mediaType == .film;
  }

  bool isTV() {
    return mediaType == .tv;
  }

  MediaTypeState copyWith({
    MediaType? mediaType,
    PodcastType? podcastType,
    FilmType? filmType,
    MusicType? musicType,
  }) => MediaTypeState(
    mediaType ?? this.mediaType,
    podcastType: podcastType ?? this.podcastType,
    filmType: filmType ?? this.filmType,
    musicType: musicType ?? this.musicType,
  );

  factory MediaTypeState.fromJson(Map<String, dynamic> json) =>
      _$MediaTypeStateFromJson(json);

  Map<String, dynamic> toJson() => _$MediaTypeStateToJson(this);
}

class MediaTypeCubit extends HydratedCubit<MediaTypeState> {
  MediaTypeCubit() : super(MediaTypeState.initial());

  // music -> film -> tv -> podcast
  void next() {
    switch (state.mediaType) {
      case .music:
        emit(state.copyWith(mediaType: .film));
      case .film:
        emit(state.copyWith(mediaType: .tv));
      case .tv:
        emit(state.copyWith(mediaType: .podcast));
      case .podcast:
        emit(state.copyWith(mediaType: .music));
      default:
        emit(state.copyWith(mediaType: .music));
    }
  }

  // music <- film <- tv <- podcast
  void previous() {
    switch (state.mediaType) {
      case .music:
        emit(state.copyWith(mediaType: .podcast));
      case .film:
        emit(state.copyWith(mediaType: .music));
      case .tv:
        emit(state.copyWith(mediaType: .film));
      case .podcast:
        emit(state.copyWith(mediaType: .tv));
      default:
        emit(state.copyWith(mediaType: .music));
    }
  }

  // all -> recent -> subscribed
  void nextPodcastType() {
    switch (state.podcastType) {
      case .all:
        emit(state.copyWith(podcastType: .recent));
      case .recent:
        emit(state.copyWith(podcastType: .subscribed));
      case .subscribed:
        emit(state.copyWith(podcastType: .all));
    }
  }

  // all -> recent -> added -> recommended
  void nextFilmType() {
    switch (state.filmType) {
      case .all:
        emit(state.copyWith(filmType: .recent));
      case .recent:
        emit(state.copyWith(filmType: .added));
      case .added:
        emit(state.copyWith(filmType: .recommended));
      case .recommended:
        emit(state.copyWith(filmType: .all));
    }
  }

  // recent -> added
  void nextMusicType() {
    switch (state.musicType) {
      case .recent:
        emit(state.copyWith(musicType: .added));
      case .added:
        emit(state.copyWith(musicType: .recent));
    }
  }

  void select(
    MediaType mediaType, {
    PodcastType? podcastType,
    FilmType? filmType,
    MusicType? musicType,
  }) {
    emit(
      state.copyWith(
        mediaType: mediaType,
        podcastType: podcastType,
        filmType: filmType,
        musicType: musicType,
      ),
    );
  }

  @override
  MediaTypeState? fromJson(Map<String, dynamic> json) =>
      MediaTypeState.fromJson(json['mediaType'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(MediaTypeState state) => {
    'mediaType': state.toJson(),
  };
}
