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

import 'media_type.dart';

class MediaTypeRepository {
  MediaTypeCubit? cubit;

  void init(MediaTypeCubit cubit) {
    this.cubit = cubit;
  }

  MediaTypeState get state {
    return cubit?.state ?? MediaTypeState.initial();
  }

  MediaType get mediaType {
    return state.mediaType;
  }

  MusicType get musicType {
    return state.musicType;
  }

  FilmType get filmType {
    return state.filmType;
  }

  PodcastType get podcastType {
    return state.podcastType;
  }
}