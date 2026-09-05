// Copyright 2023 defsub
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

import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/pages/music/track_list.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/pages/podcast/series_grid.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_grid.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';

class SearchPage extends ClientPage<SearchView> {
  final _query = StringBuffer();

  SearchPage({super.key}) : super(value: SearchView.empty());

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) async {
    if (_query.isNotEmpty) {
      await context.client.search(_query.toString(), ttl: ttl ?? Duration.zero);
    }
  }

  @override
  Widget page(BuildContext context, SearchView state) {
    return Builder(
      builder: (context) {
        final orientation = MediaQuery.of(context).orientation;
        final history = context.watch<HistoryCubit>().state.history;
        final searches = List<SearchHistory>.from(history.searches);
        searches.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        final words = searches.map((e) => e.search);
        final padding = const EdgeInsetsGeometry.only(left: 20, top: 20);

        final enableBack = orientation == .portrait;

        // check for exact matches
        final exactArtistsMatches = <Artist>[];
        if (state.hasArtists) {
          for (var a in state.artistList) {
            if (a.name.toLowerCase() == _query.toString().toLowerCase()) {
              exactArtistsMatches.add(a);
            }
          }
        }
        final exactMovieMatches = <Movie>[];
        if (state.hasMovies) {
          for (var m in state.movieList) {
            if (m.title.toLowerCase() == _query.toString().toLowerCase()) {
              exactMovieMatches.add(m);
            }
          }
        }
        final hasExactMatches =
            exactArtistsMatches.isNotEmpty || exactMovieMatches.isNotEmpty;

        return Scaffold(
          body: SliverStack(
            slivers: [
              SliverBox(
                padding: EdgeInsetsGeometry.only(left: 6, top: 4, right: 20),
                child: Row(
                  children: [
                    if (enableBack) ...[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          // TODO maybe do something better here?
                          context.app.goto(NavigationIndex.home.index);
                        },
                      ),
                    ],
                    Expanded(
                      child: Autocomplete<String>(
                        optionsBuilder: (editValue) {
                          final text = editValue.text;
                          if (text.isEmpty) {
                            return words;
                          } else {
                            final s = text.toLowerCase();
                            final options = <String>{}
                              ..add(text)
                              ..addAll(
                                words.where(
                                  (e) => e.toLowerCase().startsWith(s),
                                ),
                              )
                              ..addAll(context.search.findArtistsByName(s))
                              ..addAll(context.search.findMoviesByTitle(s));
                            return options.toList();
                          }
                        },
                        onSelected: (value) {
                          _onSubmit(context, value);
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                focusNode.requestFocus();
                              });
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onSubmitted: (value) => onFieldSubmitted(),
                                decoration: InputDecoration(
                                  hintText: 'Takeout Search',
                                  filled: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    // fully pill-shaped at typical field height
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ],
                ),
              ),
              if (hasExactMatches)
                if (exactArtistsMatches.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.artistsLabel,
                    padding: padding,
                    style: context.header2,
                  ),
                  SliverArtistGrid(exactArtistsMatches),
                ],
              if (hasExactMatches)
                if (exactMovieMatches.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.moviesLabel,
                    padding: padding,
                    style: context.header2,
                  ),
                  SliverMovieGrid(exactMovieMatches),
                ],
              if (!hasExactMatches)
                ..._sliverResults(context, state, padding: padding),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _sliverResults(
    BuildContext context,
    SearchView state, {
    required EdgeInsetsGeometry padding,
  }) {
    return [
      if (state.hasArtists) ...[
        SliverTitle(
          context.strings.artistsLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverArtistGrid(state.artistList),
      ],
      if (state.hasReleases) ...[
        SliverTitle(
          context.strings.releasesLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverAlbumGrid(state.releaseList),
      ],
      if (state.hasTracks) ...[
        SliverTitle(
          context.strings.tracksLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverTrackList(state.trackList),
      ],
      if (state.hasMovies) ...[
        SliverTitle(
          context.strings.moviesLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverMovieGrid(state.movieList),
      ],
      if (state.hasSeries) ...[
        SliverTitle(
          context.strings.seriesLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverSeriesGrid(state.seriesList),
      ],
      if (state.hasEpisodes) ...[
        SliverTitle(
          context.strings.episodesLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverEpisodeGrid(state.episodeList),
      ],
      if (state.hasTVEpisodes) ...[
        SliverTitle(
          context.strings.tvEpisodesLabel,
          padding: padding,
          style: context.header2,
        ),
        SliverTVEpisodeGrid(state.tvEpisodeList),
      ],
    ];
  }

  void _onSubmit(BuildContext context, String q) {
    _query.clear();
    _query.write(q.trim());
    if (_query.isNotEmpty) {
      context.history.add(search: _query.toString());
      load(context);
    }
  }
}
