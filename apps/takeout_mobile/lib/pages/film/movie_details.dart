import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/people.dart';
import 'package:takeout_mobile/widgets/avatar_button.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takeout_mobile/pages/film/play_movie.dart';

class MovieDetailsPage extends ClientPage<MovieView> {
  final Movie _movie;

  MovieDetailsPage(this._movie, {super.key});

  Movie get movie => _movie;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.movie(_movie.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, MovieView state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            final offsetState = context.watch<OffsetCacheCubit>().state;
            final hasProgress = offsetState.hasValue(_movie);
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background poster
                backdropImage(context, movie.backdrop),

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
                                  MediaProgress.movie(
                                    _movie,
                                    movieSmallPoster(context, movie.image),
                                  ),

                                  const SizedBox(width: 20),

                                  // Movie details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie.title,
                                          style: AppTextStyle.movieTitle,
                                        ),

                                        const SizedBox(height: 12),

                                        Text(
                                          movie.tagline,
                                          style: AppTextStyle.movieTagline,
                                        ),

                                        const SizedBox(height: 12),

                                        Wrap(
                                          children: [
                                            if (movie.hasVotes) ...[
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                movie.vote,
                                                style: AppTextStyle.movieVote,
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                            if (movie.hasRating) ...[
                                              Text(
                                                movie.rating,
                                                style: AppTextStyle.movieRating,
                                              ),
                                              SizedBox(width: 16),
                                            ],
                                            Text(
                                              '${movie.year}',
                                              style: AppTextStyle.movieYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              Duration(
                                                minutes: movie.runtime,
                                              ).inHoursMinutes,
                                              style: AppTextStyle.movieRuntime,
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
                                                  onPressed: () =>
                                                      _onGenre(context, genre),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],

                                        if (state.hasTrailers()) ...[
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              ...state.trailers!
                                                  .where((t) => t.official)
                                                  .map(
                                                    (trailer) => MyChip(
                                                      label: trailer.name,
                                                      overflow: .ellipsis,
                                                      onPressed: () {
                                                        launchUrl(
                                                          Uri.parse(
                                                            trailer.url,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => _onPlay(context, state),
                                    label: Text('Play'),
                                    icon: Icon(Icons.play_arrow),
                                  ),
                                  if (hasProgress)
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _onResume(context, state),
                                      label: Text('Resume'),
                                      icon: Icon(Icons.play_arrow),
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
                                movie.overview,
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

                      if (state.hasRelated()) ...[
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsetsGeometry.all(20),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                const SizedBox(height: 32),
                                const Text(
                                  'Related',
                                  style: AppTextStyle.movieRelatedTitle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      MovieGrid(
                        state.relatedMovies(),
                        padding: EdgeInsetsGeometry.only(
                          left: movieGridEdgeInset,
                          right: movieGridEdgeInset,
                          bottom: movieGridEdgeInset,
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
