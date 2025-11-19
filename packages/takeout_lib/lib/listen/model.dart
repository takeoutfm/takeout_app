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

import 'package:hive_ce/hive.dart';
import 'package:takeout_lib/model.dart';

class Listen extends HiveObject implements MediaTrack {
  final int retryCount;

  final DateTime listenedAt;
  @override
  final String creator;
  @override
  final String album;
  @override
  final String image;
  @override
  final String date;
  @override
  final int year;
  @override
  final String title;
  @override
  final String etag;
  @override
  final int size;
  @override
  final int number;
  @override
  final int disc;
  @override
  final String location;

  Listen(
    this.listenedAt,
    this.creator,
    this.album,
    this.image,
    this.date,
    this.year,
    this.title,
    this.etag,
    this.size,
    this.number,
    this.disc,
    this.location, {
    this.retryCount = 0,
  });

  factory Listen.fromMediaTrack(MediaTrack track, DateTime listenedAt) =>
      Listen(
        listenedAt,
        track.creator,
        track.album,
        track.image,
        track.date,
        track.year,
        track.title,
        track.etag,
        track.size,
        track.number,
        track.disc,
        track.location,
      );

  // TODO use retryCount
  Listen copyWith({int? retryCount}) => Listen(
    listenedAt,
    creator,
    album,
    image,
    date,
    year,
    title,
    etag,
    size,
    number,
    disc,
    location,
    retryCount: retryCount ?? this.retryCount,
  );
}
