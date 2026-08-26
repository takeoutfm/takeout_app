import 'dart:ui';

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
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/home/media_bar.dart';
import 'package:takeout_mobile/pages/film/genre_grid.dart';
import 'package:takeout_mobile/pages/film/genre_page.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';
import 'package:takeout_mobile/pages/music/release_details.dart';
import 'package:takeout_mobile/pages/podcast/series_details.dart';
import 'package:takeout_mobile/pages/tv/tvseries_details.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';

abstract class GridClientPage<T> extends ClientPage<T> {
  static GridClientPage<dynamic> create(
    BuildContext context,
    MediaTypeState state,
  ) {
    Widget? appBar;
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == .portrait) {
      appBar = SliverMediaBar();
    } else {
      appBar = switch (state.mediaType) {
        .music => _SliverMusicAppBar(),
        .film => _SliverFilmAppBar(),
        .podcast => _SliverPodcastAppBar(),
        _ => null,
      };
    }

    if (state.mediaType == .music || state.mediaType == .stream) {
      return HomeViewGrid(
        state,
        sliverAppBar: appBar,
        itemsFunc: (view) =>
            state.musicType == MusicType.recent ? view.released : view.added,
        coverFunc: (context, item) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: gridCover(context, item.image),
        ),
        onTap: (context, item) => _onRelease(context, item as Release),
        childAspectRatio: coverAspectRatio,
        maxCrossAxisExtent: coverGridWidth,
      );
    }

    if (state.mediaType == .film) {
      final filmType = state.filmType;
      if (filmType == .all) {
        return MoviesViewGrid(
          sliverAppBar: appBar,
          onTap: (context, movie) => _onMovie(context, movie),
        );
      } else if (filmType == .genre) {
        return MovieGenresViewGrid(
          sliverAppBar: appBar,
          onTap: (context, name) => _onMovieGenre(context, name),
        );
      }
      return HomeViewGrid(
        state,
        sliverAppBar: appBar,
        itemsFunc: (view) {
          List<Movie> result = [];
          switch (filmType) {
            case .recent:
              result = view.newMovies;
            case .added:
              result = view.addedMovies;
            case .recommended:
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
        coverFunc: (context, item) =>
            MediaProgress.movie(item as Movie, gridPoster(context, item.image)),
        onTap: (context, item) => _onMovie(context, item as Movie),
        childAspectRatio: posterAspectRatio,
        maxCrossAxisExtent: posterGridWidth,
      );
    }

    if (state.mediaType == .tv) {
      return TVShowsViewGrid(
        sliverAppBar: appBar,
        onTap: (context, item) => _onTVSeries(context, item),
      ); // XXX TODO
    }

    if (state.mediaType == .podcast) {
      final podcastType = state.podcastType;
      switch (podcastType) {
        case PodcastType.all:
          return PodcastsViewGrid(
            sliverAppBar: appBar,
            onTap: (context, series) => _onSeries(context, series),
          );
        case PodcastType.subscribed:
          return SubscribedPodcastsViewGrid(
            sliverAppBar: appBar,
            onTap: (context, series) => _onSeries(context, series),
          );
        // default: // recent
        //   return HomeViewGrid(
        //     mediaTypeState,
        //     itemsFunc: (view) => view.newSeries ?? [],
        //     coverFunc: (context, item) => ClipRRect(
        //       borderRadius: BorderRadius.circular(16),
        //       child: gridSeries(context, item.image),
        //     ),
        //     onTap: (context, item) => _onSeries(context, item as Series),
        //     childAspectRatio: seriesAspectRatio,
        //     maxCrossAxisExtent: seriesGridWidth,
        //   );
      }
    }

    throw StateError('bad mediaType: ${state.mediaType}');
  }

  final Widget? sliverAppBar;

  const GridClientPage({this.sliverAppBar, super.key});

  @override
  Future<void> reload(BuildContext context) async {
    await super.reload(context); // context requires client
    if (context.mounted) {
      await context.reload();
    }
  }

  @override
  Widget errorPage(BuildContext context, ClientError error) {
    if (error is ClientAuthError) {
      context.logout(); // will rebuild parent
      return SliverBox(child: const EmptyWidget());
    } else {
      return SliverBox(child: super.errorPage(context, error));
    }
  }

  @override
  Widget page(BuildContext context, T state) {
    return Builder(
      builder: (context) {
        final trackCacheState = context.watch<TrackCacheCubit>().state;
        final spiffCacheState = context.watch<SpiffCacheCubit>().state;
        return RefreshIndicator(
          onRefresh: () => reload(context),
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

  Widget _grid(BuildContext context, T state, SpiffTrackCacheState cache);
}

class HomeViewGrid extends GridClientPage<HomeView> {
  final MediaTypeState state;
  final double childAspectRatio;
  final double maxCrossAxisExtent;
  final Iterable<MediaAlbum> Function(HomeView) itemsFunc;
  final Widget Function(BuildContext, MediaAlbum) coverFunc;
  final void Function(BuildContext, MediaAlbum) onTap;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final Widget? header;

  const HomeViewGrid(
    this.state, {
    super.sliverAppBar,
    required this.itemsFunc,
    required this.maxCrossAxisExtent,
    required this.coverFunc,
    required this.onTap,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsetsGeometry.all(20),
    this.spacing = 12,
    this.header,
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

class MoviesViewGrid extends GridClientPage<MoviesView> {
  final void Function(BuildContext, Movie) onTap;

  const MoviesViewGrid({super.sliverAppBar, required this.onTap, super.key});

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
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
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
        ),
      ],
    );
  }
}

class MovieGenresViewGrid extends GridClientPage<IndexView> {
  final void Function(BuildContext, String) onTap;

  const MovieGenresViewGrid({
    super.sliverAppBar,
    required this.onTap,
    super.key,
  });

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.index.reload();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IndexCubit>().state;
    final view = IndexView(
      time: DateTime.now().millisecondsSinceEpoch,
      hasMovies: state.movies,
      hasMusic: state.music,
      hasPodcasts: state.podcasts,
      hasPlaylists: state.playlists,
      hasShows: state.shows,
      hasRecommendMovies: state.recommendMovies,
      movieGenres: state.movieGenres,
    );
    return page(context, view);
  }

  @override
  Widget _grid(
    BuildContext context,
    IndexView state,
    SpiffTrackCacheState cache,
  ) {
    final genres = state.movieGenres;
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180, // max width any single card can be
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final name = genres[index];
              return GenreCard(
                genre: Genre.of(name),
                onTap: () => onTap(context, name),
              );
            }, childCount: genres.length),
          ),
        ),
      ],
    );
  }
}

class TVShowsViewGrid extends GridClientPage<TVShowsView> {
  final void Function(BuildContext, TVSeries) onTap;

  const TVShowsViewGrid({super.sliverAppBar, required this.onTap, super.key});

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

class PodcastsViewGrid extends GridClientPage<PodcastsView> {
  final void Function(BuildContext, Series) onTap;
  final void Function(BuildContext, Series, Offset)? onLongPress;

  const PodcastsViewGrid({
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
    // final onLongPress = this.onLongPress;
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

class SubscribedPodcastsViewGrid extends GridClientPage<PodcastsView> {
  final void Function(BuildContext, Series) onTap;

  const SubscribedPodcastsViewGrid({
    required this.onTap,
    super.key,
    super.sliverAppBar,
  });

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) async {
    context.subscribed.reload();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscribedCubit>().state;
    return page(context, PodcastsView(series: state.series));
  }

  @override
  Widget _grid(
    BuildContext context,
    PodcastsView state,
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

void _onMovie(BuildContext context, Movie movie) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => MovieDetailsPage(movie)));

void _onMovieGenre(BuildContext context, String name) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => GenrePage(name)));

void _onTVSeries(BuildContext context, TVSeries series) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => TVSeriesDetailsPage(series)));

void _onRelease(BuildContext context, Release release) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => ReleaseDetailsPage(release)));

void _onSeries(BuildContext context, Series series) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => SeriesDetailsPage(series)));

final selectedIcon = Icons.check;

abstract class _SliverAppBar extends StatelessWidget {
  const _SliverAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.1), // slight tint helps too
          ),
        ),
      ),
      title: Wrap(spacing: 20, children: actions(context)),
    );
  }

  List<MyChip> actions(BuildContext context);
}

class _SliverMusicAppBar extends _SliverAppBar {
  @override
  List<MyChip> actions(BuildContext context) {
    final state = context.selectedMediaType.state;
    return [
      MyChip(
        icon: state.musicType == .recent ? selectedIcon : null,
        label: 'New Releases',
        onTap: () {
          context.selectedMediaType.select(.music, musicType: .recent);
        },
      ),
      MyChip(
        icon: state.musicType == .added ? selectedIcon : null,
        label: 'Recently Added',
        onTap: () {
          context.selectedMediaType.select(.music, musicType: .added);
        },
      ),
    ];
  }
}

class _SliverFilmAppBar extends _SliverAppBar {
  @override
  List<MyChip> actions(BuildContext context) {
    final state = context.selectedMediaType.state;
    final index = context.index.state;
    return [
      MyChip(
        icon: state.filmType == .all ? selectedIcon : null,
        label: 'All Movies',
        onTap: () {
          context.selectedMediaType.select(.film, filmType: .all);
        },
      ),
      if (index.movieGenres.isNotEmpty)
        MyChip(
          icon: state.filmType == .genre ? selectedIcon : null,
          label: 'Genres',
          onTap: () {
            context.selectedMediaType.select(.film, filmType: .genre);
          },
        ),
      if (index.recommendMovies)
        MyChip(
          icon: state.filmType == .recent ? selectedIcon : null,
          label: 'Recommended',
          onTap: () {
            context.selectedMediaType.select(.film, filmType: .recent);
          },
        ),
      MyChip(
        icon: state.filmType == .recent ? selectedIcon : null,
        label: 'New Releases',
        onTap: () {
          context.selectedMediaType.select(.film, filmType: .recent);
        },
      ),
      MyChip(
        icon: state.filmType == .added ? selectedIcon : null,
        label: 'Recently Added',
        onTap: () {
          context.selectedMediaType.select(.film, filmType: .added);
        },
      ),
    ];
  }
}

class _SliverPodcastAppBar extends _SliverAppBar {
  @override
  List<MyChip> actions(BuildContext context) {
    final state = context.selectedMediaType.state;
    return [
      MyChip(
        icon: state.podcastType == .all ? selectedIcon : null,
        label: 'All Podcasts',
        onTap: () {
          context.selectedMediaType.select(.podcast, podcastType: .all);
        },
      ),
      // MyChip(
      //   icon: state.podcastType == .recent ? selectedIcon : null,
      //   label: 'New Episodes',
      //   onTap: () {
      //     context.selectedMediaType.select(.podcast, podcastType: .recent);
      //   },
      // ),
      MyChip(
        icon: state.podcastType == .subscribed ? selectedIcon : null,
        label: 'Subscribed',
        onTap: () {
          context.selectedMediaType.select(.podcast, podcastType: .subscribed);
        },
      ),
    ];
  }
}
