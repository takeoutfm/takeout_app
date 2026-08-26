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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/home/grid.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return _MediaWidget(state);
  }
}

class MusicMediaWidget extends StatelessWidget {
  const MusicMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return _MediaWidget(state.copyWith(mediaType: .music));
  }
}

class FilmMediaWidget extends StatelessWidget {
  const FilmMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return _MediaWidget(state.copyWith(mediaType: .film));
  }
}

class TVMediaWidget extends StatelessWidget {
  const TVMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return _MediaWidget(state.copyWith(mediaType: .tv));
  }
}

class PodcastMediaWidget extends StatelessWidget {
  const PodcastMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return _MediaWidget(state.copyWith(mediaType: .podcast));
  }
}

class _MediaWidget extends StatelessWidget {
  final MediaTypeState state;

  const _MediaWidget(this.state);

  @override
  Widget build(BuildContext context) => GridClientPage.create(context, state);
}
