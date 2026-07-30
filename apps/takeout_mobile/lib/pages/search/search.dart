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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/artists.dart';
import 'package:takeout_mobile/pages/film.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/artist_details.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';
import 'package:takeout_mobile/pages/music/track_list.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/pages/podcast/series_grid.dart';
import 'package:takeout_mobile/pages/podcasts.dart';
import 'package:takeout_mobile/pages/release.dart';
import 'package:takeout_mobile/pages/tv.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_grid.dart';
import 'package:takeout_mobile/widgets/custom_list_tile.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';
import 'package:takeout_mobile/widgets/style.dart';
import 'package:takeout_mobile/widgets/tracks.dart';

class SearchPage extends ClientPage<SearchView> {
  final _query = StringBuffer();
  final bool allowBack;

  SearchPage({this.allowBack = true, super.key})
    : super(value: SearchView.empty());

  void _onPlay(BuildContext context, SearchView view) {
    final List<Track>? tracks = view.tracks;
    if (tracks != null && tracks.isNotEmpty) {
      final spiff = Spiff.fromMediaTracks(tracks);
      context.play(spiff);
    }
  }

  void _onDownload(BuildContext context, SearchView view) {
    final List<Track>? tracks = view.tracks;
    if (tracks != null && tracks.isNotEmpty) {
      final spiff = Spiff.fromMediaTracks(tracks);
      context.download(spiff);
    }
  }

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
        final history = context.watch<HistoryCubit>().state.history;
        final searches = List<SearchHistory>.from(history.searches);
        searches.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        final words = searches.map((e) => e.search);
        return Scaffold(
          appBar: AppBar(
            leading: allowBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: Autocomplete<String>(
              optionsBuilder: (editValue) {
                final text = editValue.text;
                if (text.isEmpty) {
                  return words;
                } else {
                  final s = text.toLowerCase();
                  final options = <String>{}
                    ..add(text)
                    ..addAll(words.where((e) => e.toLowerCase().startsWith(s)))
                    ..addAll(context.search.findArtistsByName(s));
                  return options.toList();
                }
              },
              onSelected: (value) {
                _onSubmit(context, value);
              },
            ),
          ),
          body: SliverStack(
            slivers: [
              if (state.hasArtists) ...[
                SliverTitle(
                  context.strings.artistsLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverArtistGrid(state.artistList),
              ],
              if (state.hasReleases) ...[
                SliverTitle(
                  context.strings.releasesLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverAlbumGrid(state.releaseList),
              ],
              if (state.hasTracks) ...[
                SliverTitle(
                  context.strings.tracksLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverTrackList(state.trackList),
              ],
              if (state.hasMovies) ...[
                SliverTitle(
                  context.strings.moviesLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverMovieGrid(state.movieList),
              ],
              if (state.hasSeries) ...[
                SliverTitle(
                  context.strings.seriesLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverSeriesGrid(state.seriesList),
              ],
              if (state.hasEpisodes) ...[
                SliverTitle(
                  context.strings.episodesLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverEpisodeGrid(state.episodeList),
              ],
              if (state.hasTVEpisodes) ...[
                SliverTitle(
                  context.strings.tvEpisodesLabel,
                  padding: EdgeInsetsGeometry.only(left: 20, top: 20),
                  style: context.header2,
                ),
                SliverTVEpisodeGrid(state.tvEpisodeList),
              ]
            ],
          ),
          // Column(
          //   children: [
          //     Flexible(
          //       child: ListView(
          //         children: [
          //           if (state.artists != null && state.artists!.isNotEmpty)
          //             Column(
          //               crossAxisAlignment: .start,
          //               children: [
          //                 Text(
          //                   context.strings.artistsLabel,
          //                   style: context.header2,
          //                 ),
          //                 _ArtistResults(state.artists!),
          //               ],
          //             ),
          //           if (state.releases != null && state.releases!.isNotEmpty)
          //             Column(
          //               crossAxisAlignment: .start,
          //               children: [
          //                 Text(context.strings.releasesLabel, style: context.header2),
          //                 _ReleaseResults(state.releases!),
          //               ],
          //             ),
          //           if (state.tracks != null && state.tracks!.isNotEmpty)
          //             Column(
          //               children: [
          //                 heading(context.strings.tracksLabel),
          //                 Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                   children: [
          //                     OutlinedButton.icon(
          //                       label: Text(context.strings.playLabel),
          //                       icon: const Icon(Icons.play_arrow),
          //                       onPressed: () => _onPlay(context, state),
          //                     ),
          //                     OutlinedButton.icon(
          //                       label: Text(context.strings.downloadLabel),
          //                       icon: const Icon(Icons.radio),
          //                       onPressed: () => _onDownload(context, state),
          //                     ),
          //                   ],
          //                 ),
          //                 TrackListWidget(state.tracks!),
          //               ],
          //             ),
          //           // if (state.movies != null && state.movies!.isNotEmpty)
          //           //   Column(
          //           //     children: [
          //           //       heading(context.strings.moviesLabel),
          //           //       MovieListWidget(state.movies!),
          //           //     ],
          //           //   ),
          //           // if (state.tvEpisodes != null &&
          //           //     state.tvEpisodes!.isNotEmpty)
          //           //   Column(
          //           //     children: [
          //           //       heading(context.strings.tvEpisodesLabel),
          //           //       TVEpisodeListWidget(
          //           //         state.tvEpisodes!,
          //           //         showSeasons: false,
          //           //       ),
          //           //     ],
          //           //   ),
          //           // if (state.series != null && state.series!.isNotEmpty)
          //           //   Column(
          //           //     children: [
          //           //       heading(context.strings.seriesLabel),
          //           //       SeriesListWidget(state.series!),
          //           //     ],
          //           //   ),
          //           // if (state.episodes != null && state.episodes!.isNotEmpty)
          //           //   Column(
          //           //     children: [
          //           //       heading(context.strings.episodesLabel),
          //           //       EpisodeListWidget(state.episodes!),
          //           //     ],
          //           //   ),
          //         ],
          //       ),
          //     ),
          //   ],
        );
      },
    );
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

class _ArtistResults extends StatelessWidget {
  final List<Artist> _artists;

  const _ArtistResults(this._artists);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._artists.map(
          (a) => CustomListTile(
            onTap: () => _onTap(context, a),
            title: Text(a.name),
          ),
        ),
      ],
    );
  }

  void _onTap(BuildContext context, Artist artist) {
    push(context, builder: (_) => ArtistDetailsPage(artist));
  }
}

class _ReleaseResults extends StatelessWidget {
  final List<Release> _releases;

  const _ReleaseResults(this._releases);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._releases.map(
          (r) => CustomListTile(
            onTap: () => _onTap(context, r),
            title: Text(r.name),
          ),
        ),
      ],
    );
  }

  void _onTap(BuildContext context, Release release) {
    push(context, builder: (_) => ReleaseDetailsPage(release));
  }
}
