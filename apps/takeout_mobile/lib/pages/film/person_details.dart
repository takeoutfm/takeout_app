import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/film/play_movie.dart';
import 'package:takeout_mobile/pages/people.dart';
import 'package:takeout_mobile/pages/tv/tvseries_grid.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';

class PersonDetailsPage extends ClientPage<ProfileView> {
  final Person _person;

  PersonDetailsPage(this._person, {super.key});

  Person get person => _person;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.profile(_person.peid, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ProfileView state) {
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
                // backdropImage(context, person.backdrop),

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
                                  movieSmallPoster(context, person.image),

                                  const SizedBox(width: 20),

                                  // Movie details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          person.name,
                                          style: AppTextStyle.movieTitle,
                                        ),

                                        const SizedBox(height: 12),

                                        Wrap(
                                          children: [
                                            Text(
                                              ymd(person.birthday),
                                              style: AppTextStyle.movieYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              '${person.birthplace}',
                                              style: AppTextStyle.movieRuntime,
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
                                'Bio',
                                style: AppTextStyle.movieOverviewTitle,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                '${person.bio}',
                                style: AppTextStyle.movieOverview,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (state.hasStarringMovies()) ...[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsetsGeometry.all(20),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                const SizedBox(height: 32),
                                const Text(
                                  'Starring',
                                  style: AppTextStyle.movieRelatedTitle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverMovieGrid(
                          state.movies.starring,
                          padding: EdgeInsetsGeometry.only(
                            left: movieGridEdgeInset,
                            right: movieGridEdgeInset,
                            bottom: movieGridEdgeInset,
                          ),
                        ),
                      ],

                      if (state.hasStarringShows()) ...[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsetsGeometry.all(20),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                const SizedBox(height: 32),
                                const Text(
                                  'Starring Shows',
                                  style: AppTextStyle.movieRelatedTitle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverTVSeriesGrid(
                          state.shows.starring,
                          padding: EdgeInsetsGeometry.only(
                            left: movieGridEdgeInset,
                            right: movieGridEdgeInset,
                            bottom: movieGridEdgeInset,
                          ),
                        ),
                      ],

                      if (state.hasDirecting()) ...[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsetsGeometry.all(20),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                const SizedBox(height: 32),
                                const Text(
                                  'Directing',
                                  style: AppTextStyle.movieRelatedTitle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverMovieGrid(
                          state.movies.directing,
                          padding: EdgeInsetsGeometry.only(
                            left: movieGridEdgeInset,
                            right: movieGridEdgeInset,
                            bottom: movieGridEdgeInset,
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

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => GenrePage(genre));
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
    push(context, builder: (_) => ProfileWidget(person));
  }
}
