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
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/podcasts.dart';
import 'package:takeout_mobile/release.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_mobile/tv.dart';

import 'artists.dart';
import 'nav.dart';
import 'style.dart';
import 'tracks.dart';
import 'film.dart';

class SearchWidget extends ClientPage<SearchView> {
  final _query = StringBuffer();

  SearchWidget({super.key}) : super(value: SearchView.empty());

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
    return Builder(builder: (context) {
      final history = context.watch<HistoryCubit>().state.history;
      final searches = List<SearchHistory>.from(history.searches);
      searches.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final words = searches.map((e) => e.search);
      return Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context)),
              title: Autocomplete<String>(
                optionsBuilder: (editValue) {
                  final text = editValue.text;
                  if (text.isEmpty) {
                    return words;
                  } else {
                    final s = text.toLowerCase();
                    final options = <String>{}
                      ..add(text)
                      ..addAll(
                          words.where((e) => e.toLowerCase().startsWith(s)))
                      ..addAll(context.search.findArtistsByName(s));
                    return options.toList();
                  }
                },
                onSelected: (value) {
                  _onSubmit(context, value);
                },
              )),
          body: Column(children: [
            Flexible(
                child: ListView(children: [
              if (state.artists != null && state.artists!.isNotEmpty)
                Column(children: [
                  heading(context.strings.artistsLabel),
                  _ArtistResultsWidget(state.artists!),
                ]),
              if (state.releases != null && state.releases!.isNotEmpty)
                Column(children: [
                  heading(context.strings.releasesLabel),
                  ReleaseListWidget(state.releases!),
                ]),
              if (state.tracks != null && state.tracks!.isNotEmpty)
                Column(children: [
                  heading(context.strings.tracksLabel),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                          label: Text(context.strings.playLabel),
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => _onPlay(context, state)),
                      OutlinedButton.icon(
                          label: Text(context.strings.downloadLabel),
                          icon: const Icon(Icons.radio),
                          onPressed: () => _onDownload(context, state)),
                    ],
                  ),
                  TrackListWidget(state.tracks!),
                ]),
              if (state.movies != null && state.movies!.isNotEmpty)
                Column(children: [
                  heading(context.strings.moviesLabel),
                  MovieListWidget(state.movies!),
                ]),
              if (state.tvEpisodes != null && state.tvEpisodes!.isNotEmpty)
                Column(children: [
                  heading(context.strings.tvEpisodesLabel),
                  TVEpisodeListWidget(state.tvEpisodes!, showSeasons: false),
                ]),
              if (state.series != null && state.series!.isNotEmpty)
                Column(children: [
                  heading(context.strings.seriesLabel),
                  SeriesListWidget(state.series!),
                ]),
              if (state.episodes != null && state.episodes!.isNotEmpty)
                Column(children: [
                  heading(context.strings.episodesLabel),
                  EpisodeListWidget(state.episodes!),
                ]),
            ]))
          ]));
    });
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

class _ArtistResultsWidget extends StatelessWidget {
  final List<Artist> _artists;

  const _ArtistResultsWidget(this._artists);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._artists.map((a) =>
          ListTile(onTap: () => _onTapped(context, a), title: Text(a.name)))
    ]);
  }

  void _onTapped(BuildContext context, Artist artist) {
    push(context, builder: (_) => ArtistWidget(artist));
  }
}
