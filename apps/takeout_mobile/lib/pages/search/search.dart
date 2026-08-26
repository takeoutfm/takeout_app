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
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/artist_details.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';
import 'package:takeout_mobile/pages/music/track_list.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/pages/podcast/series_grid.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_grid.dart';
import 'package:takeout_mobile/widgets/custom_list_tile.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';

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
        final padding = const EdgeInsetsGeometry.only(left: 20, top: 20);
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
            ],
          ),
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
