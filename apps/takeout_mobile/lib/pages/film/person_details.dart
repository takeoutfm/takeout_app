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
import 'package:takeout_mobile/widgets/surface_theme.dart';

class PersonDetailsPage extends ClientPage<ProfileView> {
  final Person _person;

  const PersonDetailsPage(this._person, {super.key});

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
            return SurfaceTheme(
              brightness: Brightness.dark,
              child: Builder(
                builder: (context) => SliverStack(
                  slivers: [
                    SliverFavoriteBar(onTap: () {}),
                    SliverBox(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const posterWidth = 223.0;
                          const minDetailsWidth = 300.0;
                          final hasRoom =
                              constraints.maxWidth >=
                              posterWidth + minDetailsWidth;
                          if (hasRoom) {
                            // wide view
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: .stretch,
                                children: [
                                  SizedBox(
                                    width: posterWidth,
                                    child: _profileImage(context, state),
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
                                          _profileDetails(context, state),
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
                              _profileImage(context, state),
                              const SizedBox(height: 16),
                              _profileDetails(context, state),
                            ],
                          );
                        },
                      ),
                    ),
                    if (person.bio != null)
                      SliverBox(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              context.strings.biographyLabel,
                              style: context.header2,
                            ),
                          ],
                        ),
                      ),
                    if (person.bio != null)
                      SliverBox(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            person.bio ?? '',
                            style: context.synopsis,
                          ),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileImage(BuildContext context, ProfileView state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: movieSmallPoster(context, person.image),
    );
  }

  Widget _profileDetails(BuildContext context, ProfileView state) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(person.name, style: context.header1),
        const SizedBox(height: 12),
        Wrap(
          children: [
            Text(ymd(person.birthday), style: context.body),
            SizedBox(width: 16),
            Text('${person.birthplace}', style: context.body),
          ],
        ),
      ],
    );
  }
}
