import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_grid.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background poster
                backdropImage(context, series.backdrop),

                // Dark overlay
                Container(color: Colors.black.withValues(alpha: 0.65)),

                // Blur effect
                // BackdropFilter(
                //   filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), //12
                //   child: Container(
                //     color: Colors.black.withOpacity(0.2), // 0.2
                //   ),
                // ),
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        pinned: true,
                        leading: CircleButton.back(
                          onTap: () => Navigator.pop(context),
                        ),
                        title: Text(
                          '${series.name}: ${context.strings.seasonLabel(season)}',
                        ),
                        actions: [CircleButton.favorite(onTap: () {})],
                      ),

                      SliverTitle(
                        'Episodes (${state.episodes.length})',
                        style: AppTextStyle.musicRelatedTitle,
                      ),

                      SliverTVEpisodeGrid(
                        state.episodes
                            .where((e) => e.season == _season)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
