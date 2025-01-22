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

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/client/etag.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/util.dart';

part 'model.g.dart';

Random _random = Random();

@JsonSerializable()
class Spiff {
  final int index;
  final double position;
  final Playlist playlist;
  final String type;
  final String cover;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime? lastModified;

  Spiff({
    required this.index,
    required this.position,
    required this.playlist,
    required this.type,
    this.lastModified,
  }) : cover = playlist._cover;

  int get size => playlist.tracks.fold(0, (sum, t) => sum + t.size);

  String? get creator => playlist.creator;

  String get title => playlist.title;

  String? get location => playlist.location;

  String? get date => playlist.date;

  bool get isEmpty => playlist.tracks.isEmpty;

  bool get isNotEmpty => playlist.tracks.isNotEmpty;

  @override
  bool operator ==(other) {
    if (other is Spiff) {
      return playlist.title == other.playlist.title &&
          playlist.creator == other.playlist.creator &&
          playlist.location == other.playlist.location &&
          playlist.image == other.playlist.image &&
          playlist.date == other.playlist.date &&
          playlist.tracks.length == other.playlist.tracks.length &&
          listEquals(playlist.tracks, other.playlist.tracks);
    }
    return false;
  }

  Entry operator [](int index) {
    return playlist.tracks[index];
  }

  @override
  int get hashCode {
    return Object.hash(playlist.title, playlist.creator, playlist.location,
        playlist.image, playlist.date, playlist.tracks.length, playlist.tracks);
  }

  int get length {
    return playlist.tracks.length;
  }

  bool isLocal() {
    return playlist.location?.startsWith(RegExp(r'^file')) ?? false;
  }

  bool isRemote() {
    // https, http, or relative "/api" are remote
    return playlist.location?.startsWith(RegExp(r'^(http|/api)')) ?? false;
  }

  bool isMusic() {
    return type == MediaType.music.name;
  }

  bool isVideo() {
    return type == 'video'; // film or tv are video
  }

  bool isPodcast() {
    return type == MediaType.podcast.name;
  }

  bool isStream() {
    return type == MediaType.stream.name;
  }

  // MediaType get mediaType {
  //   if (type.isEmpty) {
  //     FIXME remove after transition to require type is done
      // return MediaType.music;
    // }
    // return MediaType.of(type);
  // }

  factory Spiff.fromJson(Map<String, dynamic> json) {
    try {
      return _$SpiffFromJson(json);
    } catch (e) {
      return Spiff(
          index: 0,
          position: 0,
          playlist: Playlist(title: 'error: $e', tracks: []),
          type: MediaType.music.name);
    }
  }

  factory Spiff.fromMediaTracks(
    Iterable<MediaTrack> mediaTracks, {
    MediaType mediaType = MediaType.music,
    String title = '',
    int index = 0,
    double position = 0.0,
  }) {
    final tracks =
        mediaTracks.map<Entry>((t) => Entry.fromMediaTrack(t)).toList();
    return cleanup(Spiff(
        index: index,
        position: position,
        playlist: Playlist(title: title, tracks: tracks),
        type: mediaType.name));
  }

  Map<String, dynamic> toJson() => _$SpiffToJson(this);

  Spiff copyWith({
    int? index,
    double? position,
    Playlist? playlist,
    String? type,
    DateTime? lastModified,
  }) =>
      Spiff(
          index: index ?? this.index,
          position: position ?? this.position,
          playlist: playlist ?? this.playlist,
          type: type ?? this.type,
          lastModified: lastModified ?? this.lastModified);

  Spiff updateAt(int int, Entry entry) {
    return copyWith(playlist: playlist.updateAt(index, entry));
  }

  Spiff shuffle() {
    final newPlaylist = playlist.shuffle();
    var newIndex = index;
    if (index != -1) {
      for (var i = 0; i < newPlaylist.tracks.length; i++) {
        if (newPlaylist.tracks[i].etag == playlist.tracks[index].etag) {
          // retain current index in newly shuffled playlist
          newIndex = i;
          break;
        }
      }
    }
    return copyWith(index: newIndex, playlist: newPlaylist);
  }

  static Spiff cleanup(Spiff spiff) {
    final creator = _playlistCreator(spiff);
    final title = _playlistTitle(spiff);
    if (creator != spiff.playlist.creator || title != spiff.playlist.title) {
      final playlist = spiff.playlist.copyWith(creator: creator, title: title);
      spiff = spiff.copyWith(playlist: playlist);
    }
    return spiff;
  }

  factory Spiff.empty({String title = ''}) => Spiff(
      index: 0,
      position: 0,
      playlist: Playlist(title: title, tracks: []),
      type: MediaType.music.name);
}

@JsonSerializable()
class Entry extends DownloadIdentifier implements MediaTrack, OffsetIdentifier {
  @override
  final String creator;
  @override
  final String album;
  @override
  final String title;
  @override
  final String image;
  @override
  final String date;
  @JsonKey(name: 'location')
  final List<String> locations;
  @JsonKey(name: 'identifier')
  final List<String>? identifiers;
  @JsonKey(name: 'size')
  final List<int>? sizes;
  final int _year;

  Entry(
      {required this.creator,
      required this.album,
      required this.title,
      required this.image,
      this.date = '',
      required this.locations,
      this.identifiers,
      this.sizes})
      : _year = parseYear(date);

  Entry copyWith({
    String? title,
    // List<String>? locations,
  }) =>
      Entry(
          creator: creator,
          album: album,
          title: title ?? this.title,
          image: image,
          date: date,
          locations: locations,
          identifiers: identifiers,
          sizes: sizes);

  factory Entry.fromMediaTrack(MediaTrack track) => Entry(
      creator: track.creator,
      album: track.album,
      title: track.title,
      image: track.image,
      date: track.date,
      locations: [track.location],
      identifiers: [track.etag],
      sizes: [track.size]);

  factory Entry.fromJson(Map<String, dynamic> json) {
    try {
      return _$EntryFromJson(json);
    } catch (e) {
      if (json['creator'] == null) json['creator'] = 'no creator';
      if (json['album'] == null) json['album'] = 'no album';
      if (json['title'] == null) json['title'] = 'no title';
      if (json['image'] == null) json['image'] = '';
      return _$EntryFromJson(json);
    }
  }

  Map<String, dynamic> toJson() => _$EntryToJson(this);

  @override
  String get key {
    return ETag(etag).key;
  }

  @override
  String get etag {
    return identifiers?[0] ?? '';
  }

  @override
  String get location {
    return locations[0];
  }

  @override
  int get size {
    return sizes?[0] ?? 0;
  }

  @override
  int get disc => 1;

  @override
  int get number => 0;

  @override
  int get year => _year;
}

@JsonSerializable()
class Playlist {
  final String? location;
  final String? creator;
  final String title;
  final String? image;
  final String? date;
  @JsonKey(name: 'track')
  final List<Entry> tracks;
  final String _cover;

  Playlist(
      {this.location,
      this.creator,
      required this.title,
      this.image,
      this.date,
      required this.tracks})
      : _cover = _pickCover(image, tracks);

  Playlist copyWith({
    String? location,
    String? creator,
    String? title,
    List<Entry>? tracks,
  }) =>
      Playlist(
        location: location ?? this.location,
        creator: creator ?? this.creator,
        title: title ?? this.title,
        image: image,
        tracks: tracks ?? this.tracks,
      );

  Playlist shuffle() {
    final list = List<Entry>.from(tracks);
    list.shuffle();
    return copyWith(tracks: list);
  }

  Playlist updateAt(int index, Entry entry) {
    if (index >= 0 && index < tracks.length) {
      final newTracks = List<Entry>.from(tracks);
      newTracks[index] = entry;
      return copyWith(tracks: newTracks);
    } else {
      throw IndexError.withLength(index, tracks.length);
    }
  }

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  static String _pickCover(String? image, List<Entry> tracks) {
    if (isNotNullOrEmpty(image)) {
      return image!;
    }
    if (tracks.isEmpty) {
      return '';
    }
    for (var i = 0; i < 3; i++) {
      final pick = _random.nextInt(tracks.length);
      if (isNotNullOrEmpty(tracks[pick].image)) {
        return tracks[pick].image;
      }
    }
    try {
      return tracks.firstWhere((t) => isNotNullOrEmpty(t.image)).image;
    } on StateError {
      return '';
    }
  }
}

String spiffDate(Spiff spiff, {Entry? entry, Playlist? playlist}) {
  if (entry != null) {
    return spiff.isPodcast() ? ymd(entry.date) : entry.year.toString();
  }
  if (playlist != null && playlist.date != null) {
    return spiff.isPodcast()
        ? ymd(playlist.date!)
        : parseYear(playlist.date!).toString();
  }
  return '';
}

String playlistDate(Spiff spiff) {
  return spiffDate(spiff, playlist: spiff.playlist);
}

String _playlistCreator(Spiff spiff) {
  if (spiff.playlist.creator != null) {
    return spiff.playlist.creator!;
  }
  // use track creator(s)
  final list = <String>{}..addAll(spiff.playlist.tracks.map((e) => e.creator));
  // TODO localize, need context
  return list.length > 2 ? 'Various Artists' : list.join(', ');
}

String _playlistTitle(Spiff spiff) {
  if (spiff.playlist.title.isNotEmpty) {
    return spiff.playlist.title;
  }
  // map of album title counts
  final counts = spiff.playlist.tracks
      .map((t) => t.album)
      .fold<Map<String, int>>({}, (map, album) {
    map[album] = (map[album] ?? 0) + 1;
    return map;
  });
  // sort ascending
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (sorted.length > 2) {
    // use top n album titles
    return '${sorted.sublist(0, 2).map((e) => e.key).join(', ')}, ...';
  }
  return sorted.map((e) => e.key).join(', ');
}
