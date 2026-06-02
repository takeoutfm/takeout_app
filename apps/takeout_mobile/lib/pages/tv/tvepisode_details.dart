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
import 'package:takeout_mobile/widgets/avatar_button.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';

class TVEpisodeDetailsPage extends ClientPage<TVEpisodeView> {
  final TVEpisode _episode;

  TVEpisodeDetailsPage(this._episode, {super.key});

  TVEpisode get episode => _episode;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvEpisode(_episode.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVEpisodeView state) {
    final screen = MediaQuery.of(context).size;
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
                backdropImage(context, state.series.backdrop),

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
                          '${state.episode.se}: ${state.episode.name}',
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
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: screen.width * .9,
                                    ),
                                    height: screen.height * .5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: fillImage(context, episode.image),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => _onPlay(context, state),
                                    label: Text('Play'),
                                    icon: Icon(Icons.play_arrow),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  // Movie details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Text(
                                        //   episode.name,
                                        //   style: AppTextStyle.movieTitle,
                                        // ),
                                        //
                                        // const SizedBox(height: 12),
                                        Wrap(
                                          children: [
                                            if (episode.hasVotes) ...[
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                episode.vote,
                                                style: AppTextStyle.movieVote,
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                            if (state.series.hasRating) ...[
                                              Text(
                                                state.series.rating,
                                                style: AppTextStyle.movieRating,
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                            Text(
                                              '${episode.year}',
                                              style: AppTextStyle.movieYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              context.strings.seasonLabel(
                                                episode.season,
                                              ),
                                              style: AppTextStyle.movieYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              context.strings.episodeLabel(
                                                episode.episode,
                                              ),
                                              style: AppTextStyle.movieYear,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Synopsis
                              const Text(
                                'Synopsis',
                                style: AppTextStyle.movieOverviewTitle,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                episode.overview,
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
                                          onPressed: () =>
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
    // push(context, builder: (_) => SeasonDetailsPage(series, season));
  }

  void _onPlay(BuildContext context, TVEpisodeView view) {
    playMovie(context, TVEpisodeMediaTrack(view));
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
