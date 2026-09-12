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
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/play_video.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre_page.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/people.dart';
import 'package:takeout_mobile/pages/tv/tvseries_grid.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';

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
            return SliverStack(
              slivers: [
                SliverFavoriteBar(onTap: () {}),
                SliverBox(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        crossAxisAlignment: .start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: movieSmallPoster(context, person.image),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(person.name, style: context.header1),
                                const SizedBox(height: 12),
                                Wrap(
                                  children: [
                                    Text(
                                      ymd(person.birthday),
                                      style: context.body,
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      '${person.birthplace}',
                                      style: context.body,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.strings.biographyLabel,
                        style: context.header2,
                      ),
                      const SizedBox(height: 16),
                      Text('${person.bio}', style: context.synopsis),
                    ],
                  ),
                ),
                if (state.hasStarringMovies()) ...[
                  SliverBox(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          context.strings.starringLabel,
                          style: context.header2,
                        ),
                      ],
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
                  SliverBox(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          context.strings.starringShowsLabel,
                          style: context.header2,
                        ),
                      ],
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
                  SliverBox(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          context.strings.directingLabel,
                          style: context.header2,
                        ),
                      ],
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
    playVideo(context, VideoTrack.fromMovie(view));
  }

  void _onResume(BuildContext context, MovieView view) {
    playVideo(
      context,
      VideoTrack.fromMovie(view),
      startOffset: context.offsets.state.position(view.movie),
    );
  }

  void _onPerson(BuildContext context, Person person) {
    push(context, builder: (_) => ProfileWidget(person));
  }
}
