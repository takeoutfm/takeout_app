import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/film/movie_grid.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/pages/music/track_list.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/pages/podcast/series_grid.dart';
import 'package:takeout_mobile/pages/tv/tvepisode_grid.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';

class SearchResults extends ClientPage<SearchView> {
  final String _query;

  SearchResults(this._query, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) async {
    var query = _query.trim();
    if (query.isNotEmpty) {
      if (query.contains(':') == false &&
          query.contains('"') == false &&
          query.contains("'") == false) {
        // assume quoted search to improve results
        query = '"$query"';
      }
      await context.client.search(query, ttl: ttl ?? Duration.zero);
    }
  }

  @override
  Widget page(BuildContext context, SearchView state) {
    final padding = const EdgeInsetsGeometry.only(left: 20, top: 20);
    return SliverStack(
      slivers: [
        SliverMenuBar(title: 'Search Results', items: []),
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
    );
  }
}
