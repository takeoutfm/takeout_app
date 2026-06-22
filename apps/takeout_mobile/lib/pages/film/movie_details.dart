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
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/film/person_details.dart';
import 'package:takeout_mobile/pages/film/play_movie.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/person_avatar.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:url_launcher/url_launcher.dart';

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
            return SliverStack(
              backdrop: movie.backdrop,
              slivers: [
                SliverFavoriteBar(title: movie.title, onTap: () {}),
                SliverBox(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const posterWidth = 223.0;
                      const minDetailsWidth = 300.0;
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
                                child: _moviePoster(context, state),
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
                                    children: [
                                      _movieDetails(context, state),
                                      SizedBox(height: 16),
                                      _playButtons(context, state, hasProgress),
                                    ],
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
                          _moviePoster(context, state),
                          const SizedBox(height: 16),
                          _playButtons(context, state, hasProgress),
                          const SizedBox(height: 16),
                          _movieDetails(context, state),
                        ],
                      );
                    },
                  ),
                ),
                SliverBox(
                  padding: EdgeInsetsGeometry.only(
                    left: SliverBox.edgePadding,
                    right: SliverBox.edgePadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Synopsis
                      Text(
                        context.strings.synopsisLabel,
                        style: context.header2,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(movie.overview, style: context.bodyLarge),
                      ),
                      // Cast section
                      if (state.hasCast()) ...[
                        const SizedBox(height: 32),
                        Text(context.strings.castLabel, style: context.header2),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...state.cast!.map(
                                (c) => PersonAvatar(
                                  c.person,
                                  subtitle: c.role,
                                  onTap: () => _onPerson(context, c.person),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (state.hasCrew()) ...[
                        const SizedBox(height: 32),
                        Text(context.strings.crewLabel, style: context.header2),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...state.crew!.map(
                                (c) => PersonAvatar(
                                  c.person,
                                  subtitle: c.job,
                                  onTap: () => _onPerson(context, c.person),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (state.hasRelated()) ...[
                  SliverBox(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          context.strings.relatedLabel,
                          style: context.header2,
                        ),
                      ],
                    ),
                  ),
                ],
                SliverMovieGrid(
                  state.relatedMovies(),
                  padding: EdgeInsetsGeometry.only(
                    left: movieGridEdgeInset,
                    right: movieGridEdgeInset,
                    bottom: movieGridEdgeInset,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _playButtons(BuildContext context, MovieView state, bool hasProgress) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasProgress)
          FilledButton.icon(
            onPressed: () => _onResume(context, state),
            label: Text(context.strings.resumeLabel),
            icon: Icon(Icons.play_arrow),
          ),
        FilledButton.icon(
          onPressed: () => _onPlay(context, state),
          label: Text(context.strings.playLabel),
          icon: Icon(Icons.play_arrow),
        ),
      ],
    );
  }

  Widget _moviePoster(BuildContext context, MovieView state) {
    return MediaProgress.movie(_movie, movieSmallPoster(context, movie.image));
  }

  Widget _movieDetails(BuildContext context, MovieView state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: context.header1),
        const SizedBox(height: 12),
        if (movie.tagline.isNotEmpty) ...[
          Text(movie.tagline, style: context.tagline),
          const SizedBox(height: 12),
        ],
        Wrap(
          children: [
            if (movie.hasVotes) ...[
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 6),
              Text(movie.vote, style: context.body),
              SizedBox(width: 16),
            ],
            if (movie.hasRating) ...[
              Text(movie.rating, style: context.body),
              SizedBox(width: 16),
            ],
            Text('${movie.year}', style: context.body),
            SizedBox(width: 16),
            Text(
              Duration(minutes: movie.runtime).inHoursMinutes,
              style: context.body,
            ),
          ],
        ),
        if (state.hasDirecting()) ...[
          SizedBox(height: 16),
          Wrap(children: [_director(context, state)]),
        ],
        if (state.hasGenres()) ...[
          const SizedBox(height: 20),
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
                      onTap: () {
                        launchUrl(Uri.parse(trailer.url));
                      },
                    ),
                  ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _director(BuildContext context, MovieView state) {
    final people = state.directingPeople();
    final list = <Widget>[];
    for (var i = 0; i < people.length; i++) {
      final p = people[i];
      final name = i + 1 < people.length ? '${p.name}, ' : p.name;
      list.add(
        GestureDetector(
          onTap: () => _onPerson(context, p),
          child: Text(name, style: context.bodyLink),
        ),
      );
    }
    return Row(children: list);
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
    push(context, builder: (_) => PersonDetailsPage(person));
  }
}
