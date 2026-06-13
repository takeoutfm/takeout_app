import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre.dart';
import 'package:takeout_mobile/pages/film/person_details.dart';
import 'package:takeout_mobile/pages/film/play_movie.dart';
import 'package:takeout_mobile/pages/tv/season_details.dart';
import 'package:takeout_mobile/widgets/avatar_button.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';

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
                        actions: [CircleButton.favorite(onTap: () {})],
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsetsGeometry.all(20),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              // Movie content
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: tvSeriesSmallPoster(context, series.image),
                                  ),

                                  const SizedBox(width: 20),

                                  // Movie details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          series.name,
                                          style: AppTextStyle.movieTitle,
                                        ),

                                        const SizedBox(height: 12),

                                        Text(
                                          series.tagline,
                                          style: AppTextStyle.movieTagline,
                                        ),

                                        const SizedBox(height: 12),

                                        Wrap(
                                          children: [
                                            if (series.hasVotes) ...[
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                series.vote,
                                                style: AppTextStyle.movieVote,
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                            if (series.hasRating) ...[
                                              Text(
                                                series.rating,
                                                style: AppTextStyle.movieRating,
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                            Text(
                                              '${series.year}',
                                              style: AppTextStyle.movieYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              context.strings.seasonCount(
                                                series.seasonCount,
                                              ),
                                              style: AppTextStyle.movieYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              context.strings.episodeCount(
                                                series.episodeCount,
                                              ),
                                              style: AppTextStyle.movieYear,
                                            ),
                                          ],
                                        ),

                                        if (state.hasGenres()) ...[
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              ...state.genres!.map(
                                                (genre) => MyChip(
                                                  label: genre,
                                                  onTap: () =>
                                                      _onGenre(context, genre),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],

                                        const SizedBox(height: 16),

                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            ...seasonsList.map(
                                                  (season) => MyChip(
                                                label: context.strings.seasonLabel(season),
                                                onTap: () =>
                                                    _onSeason(context, season),
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              // Synopsis
                              const Text(
                                'Synopsis',
                                style: AppTextStyle.movieOverviewTitle,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                series.overview,
                                style: AppTextStyle.movieOverview,
                              ),

                              // Cast section
                              if (state.hasCast()) ...[
                                const SizedBox(height: 32),

                                const Text(
                                  'Cast',
                                  style: AppTextStyle.movieCastTitle,
                                ),

                                const SizedBox(height: 16),

                                SizedBox(
                                  height: 110,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      ...state.cast!.map(
                                        (cast) => AvatarButton(
                                          name: cast.person.name,
                                          imageUrl: cast.person.image,
                                          onTap: () =>
                                              _onPerson(context, cast.person),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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
