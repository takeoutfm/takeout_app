// Copyright 2025 defsub
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/art/scaffold.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/player.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';

import 'buttons.dart';
import 'nav.dart';
import 'people.dart';
import 'style.dart';

class TVSeriesWidget extends ClientPage<TVSeriesView> {
  final TVSeries _series;

  TVSeriesWidget(this._series, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvSeries(_series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVSeriesView state) {
    return scaffold(
      context,
      image: _series.image,
      body: (_) => RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            final screen = MediaQuery.of(context).size;
            final expandedHeight = screen.height / 2;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  // actions: [ ],
                  backgroundColor: Colors.black,
                  expandedHeight: expandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    // centerTitle: true,
                    // title: Text(release.name, style: TextStyle(fontSize: 15)),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        releaseSmallCover(context, _series.image),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.75),
                              end: Alignment(0.0, 0.0),
                              colors: <Color>[
                                Color(0x60000000),
                                Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: _playButton(context, state, false),
                        ),
                        // Align(
                        //     alignment: Alignment.bottomCenter,
                        //     child: _progress(context)),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: _downloadButton(context, false),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                    child: Column(
                      children: [
                        _title(context),
                        _tagline(context, state),
                        _details(context, state),
                        if (state.hasGenres()) _genres(context, state),
                        // GestureDetector(
                        //     onTap: () => _onArtist(), child: _title()),
                        // GestureDetector(
                        //     onTap: () => _onArtist(), child: _artist()),
                      ],
                    ),
                  ),
                ),
                // if (state.hasCast())
                //   SliverToBoxAdapter(child: heading(context.strings.castLabel)),
                // if (state.hasCast())
                //   SliverToBoxAdapter(child: CastListWidget(state.cast ?? [])),
                // if (state.hasCrew())
                //   SliverToBoxAdapter(child: heading(context.strings.crewLabel)),
                // if (state.hasCrew())
                //   SliverToBoxAdapter(child: CrewListWidget(state.crew ?? [])),
                // TVEpisodeGridWidget(state.episodes),
                SliverToBoxAdapter(child: TVEpisodeListWidget(state.episodes)),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget _progress(BuildContext context) {
  //   final value = context.offsets.state.value(_movie);
  //   // print('progress for ${_movie.etag} is $value');
  //   return value != null
  //       ? LinearProgressIndicator(value: value)
  //       : const EmptyWidget();
  // }

  Widget _title(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Text(
        _series.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _rating(BuildContext context, TVSeriesView state) {
    final boxColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.outline;
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(border: Border.all(color: boxColor)),
      child: Text(state.series.rating),
    );
  }

  Widget _details(BuildContext context, TVSeriesView state) {
    var list = <Widget>[];
    if (state.series.rating.isNotEmpty) {
      list.add(_rating(context, state));
    }

    final fields = <String>[];

    // year
    if (state.series.year > 1) {
      fields.add(state.series.year.toString());
    }

    // vote%
    fields.add(state.series.vote);

    list.add(
      Text(merge(fields), style: Theme.of(context).textTheme.titleSmall),
    );

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget _tagline(BuildContext context, TVSeriesView state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: Text(
        state.series.tagline,
        style: Theme.of(context).textTheme.titleMedium!,
      ),
    );
  }

  Widget _genres(BuildContext context, TVSeriesView view) {
    return Center(
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 8.0,
        runSpacing: 8.0,
        // runAlignment: WrapAlignment.spaceEvenly,
        children: [
          ...view.genres!.map(
            (g) => OutlinedButton(
              onPressed: () => _onGenre(context, g),
              child: Text(g),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playButton(BuildContext context, TVSeriesView view, bool isCached) {
    // final offsetCache = context.offsets;
    // final pos = offsetCache.state.position(_movie) ?? Duration.zero;
    // return isCached
    //     ? IconButton(
    //     icon: const Icon(Icons.play_arrow, size: 32),
    //     onPressed: () => _onPlay(context, view, pos))
    //     : StreamingButton(onPressed: () => _onPlay(context, view, pos));
    return EmptyWidget();
  }

  Widget _downloadButton(BuildContext context, bool isCached) {
    // TODO show download progress
    return isCached
        ? IconButton(icon: const Icon(iconsDownloadDone), onPressed: () => {})
        : DownloadButton(onPressed: () => _onDownload(context));
  }

  void _onDownload(BuildContext context) {
    // context.downloadMovie(_movie);
  }

  void _onGenre(BuildContext context, String genre) {
    // push(context, builder: (_) => GenreWidget(genre));
  }
}

class TVSeriesGridWidget extends StatelessWidget {
  final List<TVSeries> _series;

  const TVSeriesGridWidget(this._series, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.extent(
      maxCrossAxisExtent: posterGridWidth,
      childAspectRatio: posterAspectRatio,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [
        ..._series.map(
          (s) => GestureDetector(
            onTap: () => _onTap(context, s),
            child: GridTile(
              footer: const Material(
                color: Colors.transparent,
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(
                //         bottom: Radius.circular(4))),
                clipBehavior: Clip.antiAlias,
                child: GridTileBar(
                  backgroundColor: Colors.black26,
                  // title: Text('${m.rating}'),
                  // trailing: Text('${m.year}'),
                ),
              ),
              child: gridPoster(context, s.image),
            ),
          ),
        ),
      ],
    );
  }

  void _onTap(BuildContext context, TVSeries e) {
    push(context, builder: (_) => TVSeriesWidget(e));
  }
}

class TVEpisodeGridWidget extends StatelessWidget {
  final List<TVEpisode> _episodes;

  const TVEpisodeGridWidget(this._episodes, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.extent(
      maxCrossAxisExtent: posterGridWidth,
      childAspectRatio: posterAspectRatio,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [
        ..._episodes.map(
          (e) => GestureDetector(
            onTap: () => _onTap(context, e),
            child: GridTile(
              footer: const Material(
                color: Colors.transparent,
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(
                //         bottom: Radius.circular(4))),
                clipBehavior: Clip.antiAlias,
                child: GridTileBar(
                  backgroundColor: Colors.black26,
                  // title: Text('${m.rating}'),
                  // trailing: Text('${m.year}'),
                ),
              ),
              child: gridPoster(context, e.image),
            ),
          ),
        ),
      ],
    );
  }

  void _onTap(BuildContext context, TVEpisode e) {
    push(context, builder: (_) => TVEpisodeWidget(e));
  }
}

class TVEpisodeListWidget extends StatelessWidget {
  final List<TVEpisode> _episodes;
  final bool showSeasons;

  const TVEpisodeListWidget(
    this._episodes, {
    super.key,
    this.showSeasons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: _tiles(context));
  }

  List<Widget> _tiles(BuildContext context) {
    final list = <Widget>[];
    var season = 0;
    for (var e in _episodes) {
      final tile = ListTile(
        onTap: () => _onTap(context, e),
        leading: tileStill(context, e.smallImage),
        title: Text(e.title),
        subtitle: Text(
          merge([context.strings.episodeLabel(e.episode), ymd(e.date), e.vote]),
        ),
      );
      if (showSeasons && e.season != season) {
        season = e.season;
        list.add(largeHeading(context, context.strings.seasonLabel(season)));
      }
      list.add(tile);
    }
    return list;
  }

  void _onTap(BuildContext context, TVEpisode e) {
    push(context, builder: (_) => TVEpisodeWidget(e));
  }
}

class TVEpisodeWidget extends ClientPage<TVEpisodeView> {
  final TVEpisode _episode;

  TVEpisodeWidget(this._episode, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvEpisode(_episode.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVEpisodeView state) {
    return scaffold(
      context,
      image: _episode.image,
      body: (_) => RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            final screen = MediaQuery.of(context).size;
            final expandedHeight = screen.height / 2;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  // actions: [ ],
                  backgroundColor: Colors.black,
                  expandedHeight: expandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    // centerTitle: true,
                    // title: Text(release.name, style: TextStyle(fontSize: 15)),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        releaseSmallCover(context, _episode.image),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.75),
                              end: Alignment(0.0, 0.0),
                              colors: <Color>[
                                Color(0x60000000),
                                Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: _playButton(context, state, false),
                        ),
                        // Align(
                        //     alignment: Alignment.bottomCenter,
                        //     child: _progress(context)),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: _downloadButton(context, false),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                    child: Column(
                      children: [
                        _title(context),
                        _details(context, state),
                        _overview(context, state),
                        // GestureDetector(
                        //     onTap: () => _onArtist(), child: _title()),
                        // GestureDetector(
                        //     onTap: () => _onArtist(), child: _artist()),
                      ],
                    ),
                  ),
                ),
                if (state.hasCast())
                  SliverToBoxAdapter(child: heading(context.strings.castLabel)),
                if (state.hasCast())
                  SliverToBoxAdapter(child: CastListWidget(state.cast ?? [])),
                if (state.hasCrew())
                  SliverToBoxAdapter(child: heading(context.strings.crewLabel)),
                if (state.hasCrew())
                  SliverToBoxAdapter(child: CrewListWidget(state.crew ?? [])),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Text(
        _episode.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _rating(BuildContext context, TVEpisodeView state) {
    final boxColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.outline;
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(border: Border.all(color: boxColor)),
      child: Text(state.series.rating),
    );
  }

  Widget _overview(BuildContext context, TVEpisodeView state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Text(state.episode.overview),
    );
  }

  Widget _details(BuildContext context, TVEpisodeView state) {
    var list = <Widget>[];
    if (state.series.rating.isNotEmpty) {
      list.add(_rating(context, state));
    }

    final fields = <String>[];

    // runtime
    if (state.episode.runtime > 0) {
      fields.add(Duration(minutes: state.episode.runtime).inHoursMinutes);
    }

    fields.add(state.episode.se);

    fields.add(ymd(state.episode.date));

    fields.add(state.episode.vote);

    list.add(
      Text(merge(fields), style: Theme.of(context).textTheme.titleSmall),
    );

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget _playButton(BuildContext context, TVEpisodeView view, bool isCached) {
    final offsetCache = context.offsets;
    final pos = offsetCache.state.position(_episode) ?? Duration.zero;
    return isCached
        ? IconButton(
            icon: const Icon(Icons.play_arrow, size: 32),
            onPressed: () => _onPlay(context, view, pos),
          )
        : StreamingButton(onPressed: () => _onPlay(context, view, pos));
  }

  Widget _downloadButton(BuildContext context, bool isCached) {
    // TODO show download progress
    return isCached
        ? IconButton(icon: const Icon(iconsDownloadDone), onPressed: () => {})
        : DownloadButton(onPressed: () => _onDownload(context));
  }

  void _onPlay(BuildContext context, TVEpisodeView view, Duration startOffset) {
    playMovie(context, TVEpisodeMediaTrack(view), startOffset: startOffset);
  }

  void _onDownload(BuildContext context) {
    context.downloadTVEpisode(_episode);
  }
}

// class MovieListWidget extends StatelessWidget {
//   final List<Movie> _movies;
//
//   const MovieListWidget(this._movies, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       ..._movies.asMap().keys.toList().map((index) => ListTile(
//           onTap: () => _onTapped(context, _movies[index]),
//           leading: tilePoster(context, _movies[index].image),
//           subtitle: Text(
//               merge([_movies[index].year.toString(), _movies[index].rating])),
//           title: Text(_movies[index].title)))
//     ]);
//   }
//
//   void _onTapped(BuildContext context, Movie movie) {
//     push(context, builder: (_) => MovieWidget(movie));
//   }
// }

void playMovie(
  BuildContext context,
  MediaTrack movie, {
  Duration? startOffset,
}) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => VideoPlayer(
        movie,
        settingsRepository: context.read<SettingsRepository>(),
        tokenRepository: context.read<TokenRepository>(),
        mediaTrackResolver: context.read<MediaTrackResolver>(),
        startOffset: startOffset,
      ),
    ),
  );
}

// Note this modifies the original list.
// List<Movie> _sortByTitle(List<Movie> movies) {
//   movies.sort((a, b) => a.sortTitle.compareTo(b.sortTitle));
//   return movies;
// }
