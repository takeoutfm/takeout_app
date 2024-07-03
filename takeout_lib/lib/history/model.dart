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
import 'package:takeout_lib/spiff/model.dart';

part 'model.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class History {
  final int version = 1;
  final List<SearchHistory> searches;
  final List<SpiffHistory> spiffs;
  final Map<String, TrackHistory> tracks;

  History(
      {this.searches = const [],
      this.spiffs = const [],
      this.tracks = const {}});

  factory History.empty() => History();

  History unmodifiableCopy() => History(
      searches: List.unmodifiable(searches),
      spiffs: List.unmodifiable(spiffs),
      tracks: Map.unmodifiable(tracks));

  History copy() => History(
      searches: List.from(searches),
      spiffs: List.from(spiffs),
      tracks: Map.from(tracks));

  SpiffHistory? get lastSpiff => spiffs.isNotEmpty ? spiffs.last : null;

  Iterable<String> recentArtists() {
    final recent = List<SpiffHistory>.from(spiffs);
    recent.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return recent.toSet().toList().map((e) => e.spiff.creator ?? '');
  }

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
class SpiffHistory implements Comparable<SpiffHistory> {
  final Spiff spiff;
  final DateTime dateTime;

  const SpiffHistory(this.spiff, this.dateTime);

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
class TrackHistory {
  final String creator;
  final String album;
  final String title;
  final String image;
  final String etag;
  final int count;
  final DateTime dateTime;

  const TrackHistory(this.creator, this.album, this.title, this.image,
      this.etag, this.count, this.dateTime);

  factory TrackHistory.fromJson(Map<String, dynamic> json) =>
      _$TrackHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$TrackHistoryToJson(this);

  TrackHistory copyWith({required int count, required DateTime dateTime}) =>
      TrackHistory(creator, album, title, image, etag, count, dateTime);
}
