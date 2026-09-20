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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_grid.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';
import 'package:takeout_mobile/widgets/surface_theme.dart';

class SeasonDetailsPage extends ClientPage<TVSeriesView> {
  final TVSeries _series;
  final int _season;

  const SeasonDetailsPage(this._series, this._season, {super.key});

  TVSeries get series => _series;

  int get season => _season;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvSeries(_series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVSeriesView state) {
    final episodes = state.episodes.where((e) => e.season == _season).toList();
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return SurfaceTheme(
              brightness: Brightness.dark,
              child: Builder(
                builder: (context) => SliverStack(
                  backdrop: series.backdrop,
                  slivers: [
                    SliverFavoriteBar(
                      title: context.strings.seasonLabel(season),
                      onTap: () {},
                    ),
                    SliverTitle(
                      context.strings.episodesCount(episodes.length),
                      style: context.header1,
                    ),
                    SliverTVEpisodeGrid(episodes),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
