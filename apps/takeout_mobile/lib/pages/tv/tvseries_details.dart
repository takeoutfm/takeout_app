import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre.dart';
import 'package:takeout_mobile/pages/film/person_details.dart';
import 'package:takeout_mobile/pages/film/play_movie.dart';
import 'package:takeout_mobile/pages/tv/season_details.dart';
import 'package:takeout_mobile/widgets/avatar_button.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';

class TVSeriesDetailsPage extends ClientPage<TVSeriesView> {
  final TVSeries _series;

  TVSeriesDetailsPage(this._series, {super.key});

  TVSeries get series => _series;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvSeries(_series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVSeriesView state) {
    final seasons = <int>{};
    for (final e in state.episodes) {
      seasons.add(e.season);
    }
    final seasonsList = seasons.toList()..sort();
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            // final offsetState = context.watch<OffsetCacheCubit>().state;
            // final hasProgress = offsetState.hasValue(_movie);
            return SliverStack(
              backdrop: series.backdrop,
              slivers: [
                // SliverFavoriteBar(title: series.nameYear, onTap: () {}),
                SliverFavoriteBar(onTap: () {}),
                SliverBox(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const posterWidth = 223.0;
                      const minDetailsWidth = 225.0;
                      final hasRoom =
                          constraints.maxWidth >= posterWidth + minDetailsWidth;
                      if (hasRoom) {
                        // wide view
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: .stretch,
                            children: [
                              SizedBox(
                                width: posterWidth,
                                child: _seriesPoster(context),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    mainAxisAlignment: .spaceBetween,
                                    children: [_seriesDetails(context, state)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // tall view
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _seriesPoster(context),
                          const SizedBox(height: 16),
                          _seriesDetails(context, state),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
                SliverBox(
                  padding: EdgeInsets.only(left: 20, bottom: 20, right: 20),
                  child: _seasons(context, seasonsList),
                ),
                SliverTitle(
                  context.strings.synopsisLabel,
                  padding: EdgeInsets.only(left: 20),
                  style: context.header2,
                ),
                SliverBox(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(series.overview, style: context.synopsis),
                  ),
                ),
                SliverBox(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      if (state.hasCast()) ...[
                        Text(context.strings.castLabel, style: context.header2),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...state.cast!.map(
                                (cast) => AvatarButton(
                                  name: cast.person.name,
                                  imageUrl: cast.person.image,
                                  onTap: () => _onPerson(context, cast.person),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _seriesPoster(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: tvSeriesSmallPoster(context, series.image),
    );
  }

  Widget _seriesDetails(BuildContext context, TVSeriesView state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(series.name, style: context.header1),
        const SizedBox(height: 12),
        Text(series.tagline, style: context.tagline),
        const SizedBox(height: 12),
        Wrap(
          children: [
            if (series.hasVotes) ...[
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 6),
              Text(series.vote, style: context.details),
              SizedBox(width: 16),
            ],
            if (series.hasRating) ...[
              Text(series.rating, style: context.details),
              SizedBox(width: 16),
            ],
            Text('${series.year}', style: context.details),
          ],
        ),
        // Wrap(
        //   children: [
        //     Text(
        //       context.strings.seasonCount(series.seasonCount),
        //       style: context.details,
        //     ),
        //     SizedBox(width: 8),
        //     Text(
        //       context.strings.episodeCount(series.episodeCount),
        //       style: context.details,
        //     ),
        //   ],
        // ),
        if (state.hasGenres()) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...state.genres!.map(
                (genre) =>
                    MyChip(label: genre, onTap: () => _onGenre(context, genre)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _seasons(BuildContext context, List<int> seasonsList) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...seasonsList.map(
          (season) => MyChip(
            icon: Icons.chevron_right,
            label: context.strings.seasonLabel(season),
            onTap: () => _onSeason(context, season),
          ),
        ),
      ],
    );
  }

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => GenrePage(genre));
  }

  void _onSeason(BuildContext context, int season) {
    push(context, builder: (_) => SeasonDetailsPage(series, season));
  }

  void _onPlay(BuildContext context, MovieView view) {
    playMovie(context, MovieMediaTrack(view));
  }

  void _onResume(BuildContext context, MovieView view) {
    playMovie(
      context,
      MovieMediaTrack(view),
      startOffset: context.offsets.state.position(view.movie),
    );
  }

  void _onPerson(BuildContext context, Person person) {
    push(context, builder: (_) => PersonDetailsPage(person));
  }
}
