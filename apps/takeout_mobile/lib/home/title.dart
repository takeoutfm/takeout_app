// Copyright 2026 defsub
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/context.dart';

class NavTitleWidget extends StatelessWidget {
  const NavTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final mediaType = context.watch<MediaTypeCubit>().state.mediaType;
    final title = switch (state.navigationIndex) {
      .music => context.strings.navMusic,
      .artists => context.strings.navArtists,
      .radio => context.strings.navRadio,
      .film => context.strings.navMovies,
      .tv => context.strings.navTVShows,
      .podcast => context.strings.navPodcasts,
      .history => context.strings.navHistory,
      .player => context.strings.navPlayer,
      .search => context.strings.navSearch,
      .home => switch (mediaType) {
        .music => context.strings.navMusic,
        .podcast => context.strings.navPodcasts,
        .film => context.strings.navMovies,
        .tv => context.strings.navTVShows,
        _ => 'Takeout',
      },
    };
    return Text(title);
  }
}
