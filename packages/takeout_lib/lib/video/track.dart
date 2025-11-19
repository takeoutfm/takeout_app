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

import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/model.dart';

// TODO add location back to movie to avoid this hassle?
class MovieMediaTrack implements MediaTrack {
  MovieView view;

  MovieMediaTrack(this.view);

  @override
  String get creator => '';

  @override
  String get album => '';

  @override
  String get image => view.movie.image;

  @override
  int get year => 0;

  @override
  String get title => view.movie.title;

  @override
  String get etag => view.movie.etag;

  @override
  int get size => view.movie.size;

  @override
  int get number => 0;

  @override
  int get disc => 0;

  @override
  String get date => view.movie.date;

  @override
  String get location => view.location;
}

// TODO add location back to movie to avoid this hassle?
class TVEpisodeMediaTrack implements MediaTrack {
  TVEpisodeView view;

  TVEpisodeMediaTrack(this.view);

  @override
  String get creator => '';

  @override
  String get album => '';

  @override
  String get image => view.episode.image;

  @override
  int get year => 0;

  @override
  String get title => view.episode.title;

  @override
  String get etag => view.episode.etag;

  @override
  int get size => view.episode.size;

  @override
  int get number => 0;

  @override
  int get disc => 0;

  @override
  String get date => view.episode.date;

  @override
  String get location => view.location;
}
