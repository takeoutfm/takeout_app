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

class SeasonDetailsPage extends ClientPage<TVSeriesView> {
  final TVSeries _series;
  final int _season;

  SeasonDetailsPage(this._series, this._season, {super.key});

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
            return SliverStack(
              backdrop: series.backdrop,
              slivers: [
                SliverFavoriteBar(
                  title:
                      '${series.name}: ${context.strings.seasonLabel(season)}',
                  onTap: () {},
                ),
                SliverTitle(
                  context.strings.episodesCount(episodes.length),
                  style: context.header1,
                ),
                SliverTVEpisodeGrid(episodes),
              ],
            );
          },
        ),
      ),
    );
  }
}
