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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart' hide Offset;
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/spiff_track.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/client.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/subscribed/subscribed.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/activity.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/downloads.dart';
import 'package:takeout_mobile/link.dart';
import 'package:takeout_mobile/playlists.dart';
import 'package:takeout_mobile/settings/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'film.dart';
import 'menu.dart';
import 'nav.dart';
import 'podcasts.dart';
import 'release.dart';
import 'style.dart';
import 'tv.dart';

class HomeWidget extends StatelessWidget {
  final VoidContextCallback _onSearch;

  const HomeWidget(this._onSearch, {super.key});

  @override
  Widget build(BuildContext context) {
    final indexState = context.watch<IndexCubit>().state;
    final mediaTypeState = context.watch<MediaTypeCubit>().state;
    return _grid(context, indexState, mediaTypeState);
  }

  void _onMovie(BuildContext context, Movie movie) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => MovieWidget(movie)));

  void _onTVSeries(BuildContext context, TVSeries series) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => TVSeriesWidget(series)));

  void _onRelease(BuildContext context, Release release) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => ReleaseWidget(release)));

  void _onSeries(BuildContext context, Series series) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => SeriesWidget(series)));

  Widget _grid(
    BuildContext context,
    IndexState indexState,
    MediaTypeState mediaTypeState,
  ) {
    final mediaType = mediaTypeState.mediaType;
    final appBar = _appBar(context, indexState, mediaType);
    switch (mediaType) {
      case MediaType.music:
      case MediaType.stream:
        return HomeViewGrid(
          mediaTypeState,
          appBar,
          itemsFunc: (view) => mediaTypeState.musicType == MusicType.recent
              ? view.released
              : view.added,
          coverFunc: (context, item) => gridCover(context, item.image),
          onTap: (context, item) => _onRelease(context, item as Release),
          childAspectRatio: coverAspectRatio,
          maxCrossAxisExtent: coverGridWidth,
        );
      case MediaType.film:
        final filmType = mediaTypeState.filmType;
        return filmType == FilmType.all
            ? MoviesViewGrid(
                appBar,
                onTap: (context, item) => _onMovie(context, item),
              )
            : HomeViewGrid(
                mediaTypeState,
                appBar,
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
                coverFunc: (context, item) => gridPoster(context, item.image),
                onTap: (context, item) => _onMovie(context, item as Movie),
                childAspectRatio: posterAspectRatio,
                maxCrossAxisExtent: posterGridWidth,
              );
      case MediaType.tv:
        return TVShowsViewGrid(
          appBar,
          onTap: (context, item) => _onTVSeries(context, item),
        ); // XXX TODO
      case MediaType.podcast:
        final podcastType = mediaTypeState.podcastType;
        switch (podcastType) {
          case PodcastType.all:
            return PodcastsViewGrid(
              appBar,
              onTap: (context, series) => _onSeries(context, series),
            );
          case PodcastType.subscribed:
            return SubscribedPodcastsViewGrid(
              appBar,
              onTap: (context, series) => _onSeries(context, series),
            );
          default: // recent
            return HomeViewGrid(
              mediaTypeState,
              appBar,
              itemsFunc: (view) => view.newSeries ?? [],
              coverFunc: (context, item) => gridSeries(context, item.image),
              onTap: (context, item) => _onSeries(context, item as Series),
              childAspectRatio: seriesAspectRatio,
              maxCrossAxisExtent: seriesGridWidth,
            );
        }
    }
  }

  Widget _appBar(BuildContext context, IndexState state, MediaType mediaType) {
    const iconSize = 22.0;
    final buttons = SplayTreeMap<MediaType, Widget>(
      (a, b) => a.index.compareTo(b.index),
    );
    if (state.music) {
      buttons[MediaType.music] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.music
            ? const Icon(Icons.audiotrack)
            : const Icon(Icons.audiotrack_outlined),
        onPressed: () => _onMusicSelected(context),
      );
    }
    if (state.movies) {
      buttons[MediaType.film] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.film
            ? const Icon(Icons.movie)
            : const Icon(Icons.movie_outlined),
        onPressed: () => _onFilmSelected(context),
      );
    }
    if (state.shows) {
      buttons[MediaType.tv] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.tv
            ? const Icon(Icons.tv)
            : const Icon(Icons.tv_outlined),
        onPressed: () => _onTVSelected(context),
      );
    }
    if (state.podcasts) {
      buttons[MediaType.podcast] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.podcast
            ? const Icon(Icons.podcasts)
            : const Icon(Icons.podcasts_outlined),
        onPressed: () => _onPodcastsSelected(context),
      );
    }
    final iconBar = <Widget>[];
    iconBar.addAll(buttons.values);

    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => _onSearch(context),
      ),
      actions: [
        ...iconBar,
        popupMenu(context, [
          PopupItem.playlist(context, (context) => _onRecentTracks(context)),
          PopupItem.activity(context, (context) => _onTrackStats(context)),
          PopupItem.playlists(context, (context) => _onPlaylists(context)),
          PopupItem.divider(),
          PopupItem.settings(context, (context) => _onSettings(context)),
          PopupItem.downloads(context, (context) => _onDownloads(context)),
          PopupItem.linkLogin(context, (_) => _onLink(context)),
          PopupItem.logout(context, (_) => _onLogout(context)),
          PopupItem.divider(),
          PopupItem.about(context, (context) => _onAbout(context)),
        ]),
      ],
    );
  }

  void _onFilmSelected(BuildContext context) {
    if (context.selectedMediaType.state.isFilm()) {
      context.selectedMediaType.nextFilmType();
    } else {
      context.selectedMediaType.select(MediaType.film);
    }
  }

  void _onTVSelected(BuildContext context) {
    // TODO no subtypes yet
    context.selectedMediaType.select(MediaType.tv);
  }

  void _onMusicSelected(BuildContext context) {
    if (context.selectedMediaType.state.isMusic()) {
      context.selectedMediaType.nextMusicType();
    } else {
      context.selectedMediaType.select(MediaType.music);
    }
  }

  void _onPodcastsSelected(BuildContext context) {
    if (context.selectedMediaType.state.isPodcast()) {
      context.selectedMediaType.nextPodcastType();
    } else {
      context.selectedMediaType.select(MediaType.podcast);
    }
  }

  void _onDownloads(BuildContext context) {
    push(context, builder: (_) => const DownloadsWidget());
  }

  void _onSettings(BuildContext context) {
    push(context, builder: (_) => const SettingsWidget());
  }

  void _onRecentTracks(BuildContext context) {
    push(context, builder: (_) => TrackHistoryWidget());
  }

  void _onTrackStats(BuildContext context) {
    push(context, builder: (_) => TrackStatsWidget());
  }

  void _onPlaylists(BuildContext context) {
    push(context, builder: (_) => PlaylistsWidget());
  }

  void _onLink(BuildContext context) {
    push(context, builder: (_) => LinkWidget());
  }

  void _onLogout(BuildContext context) {
    context.logout();
  }

  void _onAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: context.strings.takeoutTitle,
      applicationVersion: appVersion,
      applicationLegalese: 'Copyleft \u00a9 2020-2025 defsub',
      applicationIcon: Image.asset(
        'assets/logo_192.png',
        width: 96,
        height: 96,
      ),
      children: <Widget>[
        InkWell(
          child: const Text(
            appHome,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blueAccent,
            ),
          ),
          onTap: () => launchUrl(Uri.parse(appHome)),
        ),
      ],
    );
  }
}

mixin _GridTile<T> {
  Widget? _tile(
    MediaAlbum item,
    SpiffTrackCacheState cache, {
    String? subtitle,
  }) {
    final title = Text(item.album);
    final cached = cache.isCached(item);
    final downloaded = cache.isDownloaded(item);
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: GridTileBar(
        backgroundColor: Colors.black26,
        title: title,
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: cached
            ? Icon(downloaded ? iconsDownloadDone : iconsDownload)
            : null,
      ),
    );
  }

  Widget _grid(BuildContext context, T state, SpiffTrackCacheState cache);
}

abstract class ViewGrid<T> extends ClientPage<T> with _GridTile<T> {
  final Widget appBar;

  ViewGrid(this.appBar, {super.key});

  @override
  Future<void> reload(BuildContext context) async {
    await super.reload(context);
    if (context.mounted) {
      await context.reload();
    }
  }

  @override
  Widget errorPage(BuildContext context, ClientError error) {
    if (error is ClientAuthError) {
      context.logout(); // will rebuild parent
      return const EmptyWidget();
    } else {
      return super.errorPage(context, error);
    }
  }

  @override
  Widget page(BuildContext context, T state) {
    return Builder(
      builder: (context) {
        final trackCacheState = context.watch<TrackCacheCubit>().state;
        final spiffCacheState = context.watch<SpiffCacheCubit>().state;
        return RefreshIndicator(
          onRefresh: () => reloadPage(context),
          child: CustomScrollView(
            slivers: [
              appBar,
              _grid(
                context,
                state,
                SpiffTrackCacheState(spiffCacheState, trackCacheState),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeViewGrid extends ViewGrid<HomeView> {
  final MediaTypeState state;
  final double childAspectRatio;
  final double maxCrossAxisExtent;
  final Iterable<MediaAlbum> Function(HomeView) itemsFunc;
  final Widget Function(BuildContext, MediaAlbum) coverFunc;
  final void Function(BuildContext, MediaAlbum) onTap;

  HomeViewGrid(
    this.state,
    super.appBar, {
    required this.itemsFunc,
    required this.maxCrossAxisExtent,
    required this.coverFunc,
    required this.onTap,
    this.childAspectRatio = 1.0,
    super.key,
  });

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.home(ttl: ttl);
  }

  @override
  Widget _grid(
    BuildContext context,
    HomeView state,
    SpiffTrackCacheState cache,
  ) {
    return SliverGrid.extent(
      childAspectRatio: childAspectRatio,
      maxCrossAxisExtent: maxCrossAxisExtent,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        ...itemsFunc(state).map(
          (i) => GestureDetector(
            onTap: () => onTap(context, i),
            child: GridTile(
              footer: _tile(
                i,
                cache,
                subtitle: i.creator.isNotEmpty ? i.creator : null,
              ),
              child: coverFunc(context, i),
            ),
          ),
        ),
      ],
    );
  }
}

class MoviesViewGrid extends ViewGrid<MoviesView> {
  final void Function(BuildContext, Movie) onTap;

  MoviesViewGrid(super.appBar, {required this.onTap, super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.movies(ttl: ttl);
  }

  @override
  Widget _grid(
    BuildContext context,
    MoviesView state,
    SpiffTrackCacheState cache,
  ) {
    return SliverGrid.extent(
      childAspectRatio: posterAspectRatio,
      maxCrossAxisExtent: posterGridWidth,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        ...state.movies.map(
          (i) => GestureDetector(
            onTap: () => onTap(context, i),
            child: GridTile(
              footer: _tile(i, cache),
              child: gridPoster(context, i.image),
            ),
          ),
        ),
      ],
    );
  }
}

class TVShowsViewGrid extends ViewGrid<TVShowsView> {
  final void Function(BuildContext, TVSeries) onTap;

  TVShowsViewGrid(super.appBar, {required this.onTap, super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.shows(ttl: ttl);
  }

  @override
  Widget _grid(
    BuildContext context,
    TVShowsView state,
    SpiffTrackCacheState cache,
  ) {
    return SliverGrid.extent(
      childAspectRatio: posterAspectRatio,
      maxCrossAxisExtent: posterGridWidth,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        ...state.series.map(
          (i) => GestureDetector(
            onTap: () => onTap(context, i),
            child: GridTile(
              footer: _tile(i, cache),
              child: gridPoster(context, i.image),
            ),
          ),
        ),
      ],
    );
  }
}

class PodcastsViewGrid extends ViewGrid<PodcastsView> {
  final void Function(BuildContext, Series) onTap;
  final void Function(BuildContext, Series, Offset)? onLongPress;

  PodcastsViewGrid(
    super.appBar, {
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.podcasts(ttl: ttl);
  }

  @override
  Widget _grid(
    BuildContext context,
    PodcastsView state,
    SpiffTrackCacheState cache,
  ) {
    final onLongPress = this.onLongPress;
    return SliverGrid.extent(
      childAspectRatio: seriesAspectRatio,
      maxCrossAxisExtent: seriesGridWidth,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        ...state.series.map(
          (i) => GestureDetector(
            onTap: () => onTap(context, i),
            onLongPressStart: onLongPress != null
                ? (details) => onLongPress(context, i, details.globalPosition)
                : null,
            child: GridTile(
              footer: _tile(i, cache),
              child: gridSeries(context, i.image),
            ),
          ),
        ),
      ],
    );
  }
}

class SubscribedPodcastsViewGrid extends StatelessWidget
    with _GridTile<SubscribedState> {
  final Widget appBar;
  final void Function(BuildContext, Series) onTap;

  SubscribedPodcastsViewGrid(this.appBar, {required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final state = context.watch<SubscribedCubit>().state;
        final trackCacheState = context.watch<TrackCacheCubit>().state;
        final spiffCacheState = context.watch<SpiffCacheCubit>().state;
        return RefreshIndicator(
          onRefresh: () => reload(context),
          child: CustomScrollView(
            slivers: [
              appBar,
              _grid(
                context,
                state,
                SpiffTrackCacheState(spiffCacheState, trackCacheState),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> reload(BuildContext context) async {
    context.subscribed.reload();
  }

  @override
  Widget _grid(
    BuildContext context,
    SubscribedState state,
    SpiffTrackCacheState cache,
  ) {
    return SliverGrid.extent(
      childAspectRatio: seriesAspectRatio,
      maxCrossAxisExtent: seriesGridWidth,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        ...state.series.map(
          (i) => GestureDetector(
            onTap: () => onTap(context, i),
            child: GridTile(
              footer: _tile(i, cache),
              child: gridSeries(context, i.image),
            ),
          ),
        ),
      ],
    );
  }
}
