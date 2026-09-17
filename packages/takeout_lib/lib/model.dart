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

abstract class MediaEntry {
  String get creator;

  String get album;

  String get image;

  String get date;

  int get year;
}

abstract class MediaAlbum implements MediaEntry {}

abstract class MediaTrack implements MediaEntry {
  String get title;

  String get etag;

  int get size;

  int get number;

  int get disc;

  // 1999-07-27T00:00:00Z
  // 2022-02-03T09:21:26-08:00
  // String get date;

  String get location;
}

class SimpleTrack implements MediaTrack {
  final String creator;
  final String album;
  final String image;
  final String date;
  final int year;
  final String title;
  final String etag;
  final int size;
  final int number;
  final int disc;
  final String location;

  SimpleTrack._({
    required this.creator,
    required this.album,
    required this.image,
    required this.date,
    required this.year,
    required this.title,
    required this.etag,
    required this.size,
    required this.number,
    required this.disc,
    required this.location,
  });

  factory SimpleTrack._empty() => SimpleTrack._(
    creator: '',
    album: '',
    image: '',
    date: '',
    year: 0,
    title: '',
    etag: '',
    size: 0,
    number: 0,
    disc: 0,
    location: '',
  );

  SimpleTrack copyWith({String? creator, String? title, String? image}) =>
      SimpleTrack._(
        creator: creator ?? this.creator,
        album: album,
        image: image ?? this.image,
        date: date,
        year: year,
        title: title ?? this.title,
        etag: etag,
        size: size,
        number: number,
        disc: disc,
        location: location,
      );

  factory SimpleTrack.fromLiveTrack(LiveTrack track) {
    ({String? artist, String title}) parseArtistTitle(String title) {
      final regex = RegExp(r'^(.+?)\s*-\s*(.+)$');
      final match = regex.firstMatch(title);
      if (match == null) {
        return (artist: null, title: title);
      }
      return (
        artist: match.group(1)?.trim(),
        title: match.group(2)?.trim() ?? title,
      );
    }

    // should be "artist - title"
    final result = parseArtistTitle(track.title);
    if (result.artist != null) {
      return SimpleTrack._empty().copyWith(
        creator: result.artist,
        title: result.title,
        image: track.image,
      );
    } else {
      return SimpleTrack._empty().copyWith(
        title: track.title,
        image: track.image,
      );
    }
  }
}

abstract class LiveTrack {
  String get name; // name of radio live stream

  String get title; // track title (StreamTitle)

  String get image; // track image (StreamUrl)
}

class IcyTrack implements LiveTrack {
  @override
  final String name;
  @override
  final String title;
  @override
  final String image;

  IcyTrack(this.name, this.title, this.image);
}
