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
import 'package:takeout_mobile/widgets/focus_item.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';
import 'package:takeout_mobile/widgets/style.dart';
import 'package:takeout_mobile/widgets/text.dart';

mixin _GridTile<T> {
  Widget? _tile(
    BuildContext context,
    MediaAlbum item,
    SpiffTrackCacheState cache, {
    String? subtitle,
  }) {
    final title = Text(item.album, style: context.gridTitle);
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
        subtitle: OptionalText(subtitle, style: context.gridSubtitle),
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
  final EdgeInsetsGeometry padding;
  final double spacing;

  HomeViewGrid(
    this.state, {
    super.sliverAppBar,
    required this.itemsFunc,
    required this.maxCrossAxisExtent,
    required this.coverFunc,
    required this.onTap,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsetsGeometry.all(20),
    this.spacing = 12,
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
    // this grid supports multiple media types so need to see
    // what this is to show the correct subtitle
    final creator = (MediaAlbum i) {
      if (i is Movie) {
        return '${i.year}';
      } else if (i is Series) {
        return i.creator;
      }
      return i.creator;
    };

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.extent(
        childAspectRatio: childAspectRatio,
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        children: [
          ...itemsFunc(state).map(
            (i) => SliverGridTile(
              image: coverFunc(context, i),
              title: i.album,
              subtitle: creator(i),
              onTap: () => onTap(context, i),
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
            (i) => SliverGridTile(
              image: MediaProgress.movie(i, gridPoster(context, i.image)),
              title: i.album,
              subtitle: '${i.year}',
              onTap: () => onTap(context, i),
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
    return SliverPadding(
      padding: EdgeInsetsGeometry.all(20),
      sliver: SliverGrid.extent(
        childAspectRatio: posterAspectRatio,
        maxCrossAxisExtent: posterGridWidth,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          ...state.series.map(
            (i) => SliverGridTile(
              image: gridPoster(context, i.image),
              title: i.album,
              subtitle: '${i.year}',
              onTap: () => onTap(context, i),
            ),
          ),
        ],
      ),
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
    return SliverPadding(
      padding: EdgeInsetsGeometry.all(20),
      sliver: SliverGrid.extent(
        childAspectRatio: seriesAspectRatio,
        maxCrossAxisExtent: seriesGridWidth,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          ...state.series.map(
            (i) => SliverGridTile(
              image: gridSeries(context, i.image),
              title: i.album,
              subtitle: i.creator,
              onTap: () => onTap(context, i),
            ),
          ),
        ],
      ),
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
    return SliverPadding(
      padding: EdgeInsetsGeometry.all(20),
      sliver: SliverGrid.extent(
        childAspectRatio: seriesAspectRatio,
        maxCrossAxisExtent: seriesGridWidth,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          ...state.series.map(
            (i) => SliverGridTile(
              image: gridSeries(context, i.image),
              title: i.album,
              subtitle: i.creator,
              onTap: () => onTap(context, i),
            ),
          ),
        ],
      ),
    );
  }
}
