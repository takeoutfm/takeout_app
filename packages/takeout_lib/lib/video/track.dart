// Copyright 2025 defsub
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

import 'package:json_annotation/json_annotation.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/spiff/model.dart';

part 'track.g.dart';

enum VideoTrackType { movie, tvEpisode }

@JsonSerializable()
class VideoTrack implements MediaTrack {
  final VideoTrackType type;
  @override
  final String title;
  @override
  final int year;
  final String director;
  @override
  final String image;
  @override
  final String etag;
  @override
  final int size;
  @override
  final String date;
  @override
  final String location;
  final String? collection;

  VideoTrack(
    this.type, {
    required this.title,
    required this.year,
    required this.director,
    required this.image,
    required this.etag,
    required this.size,
    required this.date,
    required this.location,
    this.collection,
  });

  factory VideoTrack.fromMovie(MovieView view) => VideoTrack(
    .movie,
    title: view.movie.title,
    year: view.movie.year,
    director: view.hasDirecting() ? view.directingPeople().first.name : '',
    image: view.movie.image,
    etag: view.movie.etag,
    size: view.movie.size,
    date: view.movie.date,
    collection: view.collection?.name,
    location: view.location,
  );

  factory VideoTrack.fromTVEpisode(TVEpisodeView view) => VideoTrack(
    .tvEpisode,
    title: view.episode.title,
    year: view.episode.year,
    director: view.hasDirecting() ? view.directingPeople().first.name : '',
    image: view.episode.image,
    etag: view.episode.etag,
    size: view.episode.size,
    date: view.episode.date,
    collection: view.episode.se, // use S#E# for matching
    location: view.location,
  );

  factory VideoTrack.fromEntry(Entry entry) => VideoTrack(
    .movie, // TODO assume movie
    title: entry.title,
    year: entry.year,
    director: '',
    image: entry.image,
    etag: entry.etag,
    size: entry.size,
    date: entry.date,
    collection: null,
    location: entry.location,
  );

  @override
  String get creator => director;

  @override
  String get album => collection ?? '';

  @override
  int get number => 0;

  @override
  int get disc => 0;

  factory VideoTrack.fromJson(Map<String, dynamic> json) =>
      _$VideoTrackFromJson(json);

  Map<String, dynamic> toJson() => _$VideoTrackToJson(this);
}
