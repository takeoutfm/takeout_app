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

import 'package:json_annotation/json_annotation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/video/track.dart';

part 'model.g.dart';

abstract class HistoryEntry {
  String get title;
  String get image;
  DateTime get dateTime;
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class History {
  final int version = 1;
  final List<SearchHistory> searches;
  final List<SpiffHistory> spiffs;
  final Map<String, TrackHistory> tracks;
  final List<StreamHistory> stream;
  final List<VideoHistory> videos;

  History({
    this.searches = const [],
    this.spiffs = const [],
    this.tracks = const {},
    this.stream = const [],
    this.videos = const [],
  });

  factory History.empty() => History();

  History unmodifiableCopy() => History(
    searches: List.unmodifiable(searches),
    spiffs: List.unmodifiable(spiffs),
    tracks: Map.unmodifiable(tracks),
    stream: List.unmodifiable(stream),
    videos: List.unmodifiable(videos),
  );

  History copy() => History(
    searches: List.from(searches),
    spiffs: List.from(spiffs),
    tracks: Map.from(tracks),
    stream: List.from(stream),
    videos: List.from(videos),
  );

  SpiffHistory? get lastSpiff => spiffs.isNotEmpty ? spiffs.last : null;

  StreamHistory? get lastStreamHistory =>
      stream.isNotEmpty ? stream.last : null;

  VideoHistory? get latestVideo => videos.isNotEmpty ? videos.last : null;

  Iterable<String> recentArtists({int? limit}) {
    final recent = List<SpiffHistory>.from(
      spiffs.where((spiff) => spiff.spiff.isMusic),
    );
    recent.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final artists = recent.map((spiff) => spiff.spiff.creator);
    final seen = <String>{};
    final result = <String>[];
    for (final a in artists) {
      if (a != null && seen.add(a)) {
        result.add(a);
      }
    }
    return limit != null && result.length > limit
        ? result.sublist(0, limit)
        : result;
  }

  // Map<String, TrackHistory> trackKeyMap() {
  //   final oldest = List<TrackHistory>.from(tracks.values);
  //   oldest.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  //
  //   // oldest first
  //   return LinkedHashMap<String, TrackHistory>.fromIterable(oldest,
  //       key: (e) => ETag((e as TrackHistory).etag).key,
  //       value: (e) => e as TrackHistory);
  // }

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SearchHistory implements Comparable<SearchHistory> {
  final String search;
  final DateTime dateTime;

  SearchHistory(this.search, this.dateTime);

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);

  @override
  int compareTo(SearchHistory other) {
    return search.compareTo(other.search);
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SpiffHistory implements Comparable<SpiffHistory>, HistoryEntry {
  final Spiff spiff;
  @override
  final DateTime dateTime;

  const SpiffHistory(this.spiff, this.dateTime);

  @override
  String get title => spiff.title;

  @override
  String get image => spiff.cover;

  factory SpiffHistory.fromJson(Map<String, dynamic> json) =>
      _$SpiffHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$SpiffHistoryToJson(this);

  @override
  int compareTo(SpiffHistory other) {
    return spiff == other.spiff ? 0 : dateTime.compareTo(other.dateTime);
  }

  SpiffHistory copyWith({Spiff? spiff}) =>
      SpiffHistory(spiff ?? this.spiff, dateTime);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class TrackHistory implements HistoryEntry {
  final String creator;
  final String album;
  @override
  final String title;
  @override
  final String image;
  final String etag;
  final int count;
  @override
  final DateTime dateTime;

  const TrackHistory(
    this.creator,
    this.album,
    this.title,
    this.image,
    this.etag,
    this.count,
    this.dateTime,
  );

  factory TrackHistory.from(MediaTrack track, {DateTime? dateTime}) =>
      TrackHistory(
        track.creator,
        track.album,
        track.title,
        track.image,
        track.etag,
        1,
        dateTime ?? DateTime.now(),
      );

  factory TrackHistory.fromJson(Map<String, dynamic> json) =>
      _$TrackHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$TrackHistoryToJson(this);

  TrackHistory copyWith({required int count, required DateTime dateTime}) =>
      TrackHistory(creator, album, title, image, etag, count, dateTime);

  TrackHistory increment(int value, {DateTime? dateTime}) =>
      copyWith(count: count + value, dateTime: dateTime ?? DateTime.now());
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StreamHistory implements LiveTrack, HistoryEntry {
  @override
  final String name; // stream name
  @override
  final String title;
  @override
  final String image;
  @override
  final DateTime dateTime;

  const StreamHistory(this.name, this.title, this.image, this.dateTime);

  factory StreamHistory.from(LiveTrack track, {DateTime? dateTime}) =>
      StreamHistory(
        track.name,
        track.title,
        track.image,
        dateTime ?? DateTime.now(),
      );

  StreamHistory copyWith(DateTime newTime) =>
      StreamHistory(name, title, image, newTime);

  factory StreamHistory.fromJson(Map<String, dynamic> json) =>
      _$StreamHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$StreamHistoryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class VideoHistory implements HistoryEntry {
  final VideoTrack video;
  final Offset offset;
  final int? selectedAudioTrack;
  final int? selectedSubtitleTrack;
  @override
  final DateTime dateTime;

  const VideoHistory({
    required this.video,
    required this.offset,
    required this.dateTime,
    this.selectedAudioTrack,
    this.selectedSubtitleTrack,
  });

  factory VideoHistory.from(
    VideoTrack video, {
    Offset? offset,
    int? selectedAudioTrack,
    int? selectedSubtitleTrack,
    DateTime? dateTime,
  }) => VideoHistory(
    video: video,
    offset: offset ?? Offset.now(etag: video.etag, offset: Duration.zero),
    selectedAudioTrack: selectedAudioTrack,
    selectedSubtitleTrack: selectedSubtitleTrack,
    dateTime: dateTime ?? DateTime.now(),
  );

  @override
  String get title => video.title;

  int get year => video.year;

  @override
  String get image => video.image;

  bool get isMovie => video.type == .movie;

  bool get isTVEpisode => video.type == .tvEpisode;

  factory VideoHistory.fromJson(Map<String, dynamic> json) =>
      _$VideoHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$VideoHistoryToJson(this);

  VideoHistory copyWith({
    required DateTime dateTime,
    Offset? offset,
    int? selectedAudioTrack,
    int? selectedSubtitleTrack,
  }) => VideoHistory(
    video: video,
    offset: offset ?? this.offset,
    selectedAudioTrack: selectedAudioTrack ?? this.selectedAudioTrack,
    selectedSubtitleTrack: selectedSubtitleTrack ?? this.selectedSubtitleTrack,
    dateTime: dateTime,
  );
}
