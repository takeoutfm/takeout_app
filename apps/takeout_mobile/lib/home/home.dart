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
import 'package:takeout_lib/api/model.dart' hide Offset;
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/home/grid.dart';
import 'package:takeout_mobile/home/media_bar.dart';
import 'package:takeout_mobile/pages/film.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';
import 'package:takeout_mobile/pages/podcast/series_details.dart';
import 'package:takeout_mobile/pages/podcasts.dart';
import 'package:takeout_mobile/pages/release.dart';
import 'package:takeout_mobile/pages/tv.dart';
import 'package:takeout_mobile/pages/tv/tvseries_details.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return MediaTypeWidget(state);
  }
}

class MusicMediaWidget extends StatelessWidget {
  const MusicMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return MediaTypeWidget(state.copyWith(mediaType: .music));
  }
}

class FilmMediaWidget extends StatelessWidget {
  const FilmMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return MediaTypeWidget(state.copyWith(mediaType: .film));
  }
}

class TVMediaWidget extends StatelessWidget {
  const TVMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return MediaTypeWidget(state.copyWith(mediaType: .tv));
  }
}

class PodcastMediaWidget extends StatelessWidget {
  const PodcastMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MediaTypeCubit>().state;
    return MediaTypeWidget(state.copyWith(mediaType: .podcast));
  }
}

class MediaTypeWidget extends StatelessWidget {
  final MediaTypeState state;

  const MediaTypeWidget(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return _grid(context, state);
  }

  void _onMovie(BuildContext context, Movie movie) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => MovieDetailsPage(movie)));

  void _onTVSeries(BuildContext context, TVSeries series) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => TVSeriesDetailsPage(series)));

  void _onRelease(BuildContext context, Release release) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => ReleaseDetailsPage(release)));

  void _onSeries(BuildContext context, Series series) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => SeriesDetailsPage(series)));

  Widget _grid(BuildContext context, MediaTypeState mediaTypeState) {
    final mediaType = mediaTypeState.mediaType;
    final mediaBar = MediaQuery.of(context).orientation == .portrait
        ? SliverMediaBar()
        : null;
    switch (mediaType) {
      case MediaType.music:
      case MediaType.stream:
        return HomeViewGrid(
          mediaTypeState,
          sliverAppBar: mediaBar,
          itemsFunc: (view) => mediaTypeState.musicType == MusicType.recent
              ? view.released
              : view.added,
          coverFunc: (context, item) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: gridCover(context, item.image),
          ),
          onTap: (context, item) => _onRelease(context, item as Release),
          childAspectRatio: coverAspectRatio,
          maxCrossAxisExtent: coverGridWidth,
        );
      case MediaType.film:
        final filmType = mediaTypeState.filmType;
        return filmType == FilmType.all
            ? MoviesViewGrid(
                sliverAppBar: mediaBar,
                onTap: (context, item) => _onMovie(context, item),
              )
            : HomeViewGrid(
                mediaTypeState,
                sliverAppBar: mediaBar,
                itemsFunc: (view) {
                  List<Movie> result = [];
                  switch (filmType) {
                    case FilmType.recent:
                      result = view.newMovies;
                    case FilmType.added:
                      result = view.addedMovies;
                    case FilmType.recommended:
                      final recommended = view.recommendMovies;
                      if (recommended != null && recommended.isNotEmpty) {
                        // TODO only takes first recommendation
                        result = recommended.first.movies ?? [];
                      }
                    default:
                      result = [];
                  }
                  return result;
                },
                coverFunc: (context, item) => MediaProgress.movie(
                  item as Movie,
                  gridPoster(context, item.image),
                ),
                onTap: (context, item) => _onMovie(context, item as Movie),
                childAspectRatio: posterAspectRatio,
                maxCrossAxisExtent: posterGridWidth,
              );
      case MediaType.tv:
        return TVShowsViewGrid(
          sliverAppBar: mediaBar,
          onTap: (context, item) => _onTVSeries(context, item),
        ); // XXX TODO
      case MediaType.podcast:
        final podcastType = mediaTypeState.podcastType;
        switch (podcastType) {
          case PodcastType.all:
            return PodcastsViewGrid(
              sliverAppBar: mediaBar,
              onTap: (context, series) => _onSeries(context, series),
            );
          case PodcastType.subscribed:
            return SubscribedPodcastsViewGrid(
              appBar: mediaBar,
              onTap: (context, series) => _onSeries(context, series),
            );
          default: // recent
            return HomeViewGrid(
              mediaTypeState,
              sliverAppBar: mediaBar,
              itemsFunc: (view) => view.newSeries ?? [],
              coverFunc: (context, item) => ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: gridSeries(context, item.image),
              ),
              onTap: (context, item) => _onSeries(context, item as Series),
              childAspectRatio: seriesAspectRatio,
              maxCrossAxisExtent: seriesGridWidth,
            );
        }
    }
  }
}
