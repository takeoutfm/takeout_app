import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';

class SeriesDetailsPage extends ClientPage<SeriesView> {
  final Series _series;

  SeriesDetailsPage(this._series, {super.key});

  Series get series => _series;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.series(_series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, SeriesView state) {
    final episodes = List<Episode>.from(
      state.episodes.map(
        (e) => e.copyWith(album: state.series.title),
        // (e) => e.copyWith(album: state.series.title, image: state.series.image),
      ),
    );
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return SliverStack(
              slivers: [
                SliverMenuBar(
                  title: series.title,
                  items: [
                    PopupItem.divider(),
                    PopupItem.reload(context, (_) => reloadPage(context)),
                  ],
                ),
                if (episodes.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.episodesCount(episodes.length),
                    style: context.header2,
                  ),
                  SliverEpisodeGrid(
                    episodes,
                    padding: EdgeInsetsGeometry.only(
                      left: albumGridEdgeInset,
                      right: albumGridEdgeInset,
                      bottom: albumGridEdgeInset,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // void _onGenre(BuildContext context, String genre) {
  //   push(context, builder: (_) => AllArtistsGrid(genre: genre));
  // }
  //
  // void _onSingles(BuildContext context, ArtistView state) {
  //   pushSpiff(
  //     ref: '/music/artists/${_artist.id}/singles',
  //     context,
  //         (client, {Duration? ttl}) =>
  //         client.artistSinglesPlaylist(_artist.id, ttl: ttl),
  //   );
  // }
  //
  // void _onPopular(BuildContext context, ArtistView state) {
  //   pushSpiff(
  //     ref: '/music/artists/${_artist.id}/popular',
  //     context,
  //         (client, {Duration? ttl}) =>
  //         client.artistPopularPlaylist(_artist.id, ttl: ttl),
  //   );
  // }

  // void _onPlay(BuildContext context, ReleaseView view) {
  //   context.playlist.replace(
  //     _release.reference,
  //     creator: _release.creator,
  //     title: _release.name,
  //   );
  // }
  //
  // void _onArtist(BuildContext context, ReleaseView view) {
  //   push(context, builder: (_) => ArtistWidget(view.artist));
  // }
  //
  // void _onShufflePlay(BuildContext context) {
  //   context.playlist.replace(
  //     _release.reference,
  //     creator: _release.creator,
  //     title: _release.name,
  //     shuffle: true,
  //   );
  // }
  //
  // void _onDownload(BuildContext context, ReleaseView view) {
  //   context.downloadRelease(view.release);
  // }
  //
  // void _onPlaylistAppend(BuildContext context, ReleaseView state) {
  //   showPlaylistAppend(context, state.release.reference);
  // }
}
