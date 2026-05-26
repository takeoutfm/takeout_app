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
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/subscribed/subscribed.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/style.dart';

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
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: GridTileBar(
        backgroundColor: Colors.black.withValues(alpha: 0.65),
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
  final Widget? sliverAppBar;

  ViewGrid({this.sliverAppBar, super.key});

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
              ?sliverAppBar,
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
    this.state, {
    super.sliverAppBar,
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
    return SliverPadding(
      padding: EdgeInsetsGeometry.all(20),
      sliver: SliverGrid.extent(
        childAspectRatio: childAspectRatio,
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
      ),
    );
  }
}

class MoviesViewGrid extends ViewGrid<MoviesView> {
  final void Function(BuildContext, Movie) onTap;

  MoviesViewGrid({super.sliverAppBar, required this.onTap, super.key});

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
    return SliverPadding(
      padding: EdgeInsetsGeometry.all(20),
      sliver: SliverGrid.extent(
        childAspectRatio: posterAspectRatio,
        maxCrossAxisExtent: posterGridWidth,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          ...state.movies.map(
            (i) => GestureDetector(
              onTap: () => onTap(context, i),
              child: GridTile(
                footer: _tile(i, cache),
                child: MediaProgress.movie(i, gridPoster(context, i.image)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TVShowsViewGrid extends ViewGrid<TVShowsView> {
  final void Function(BuildContext, TVSeries) onTap;

  TVShowsViewGrid({super.sliverAppBar, required this.onTap, super.key});

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

  PodcastsViewGrid({
    super.sliverAppBar,
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
  final Widget? appBar;
  final void Function(BuildContext, Series) onTap;

  SubscribedPodcastsViewGrid({this.appBar, required this.onTap, super.key});

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
              ?appBar,
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
