import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';
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
    // final releaseUrl = 'https://musicbrainz.org/release/${_release.reid}';
    // final releaseGroupUrl =
    //     'https://musicbrainz.org/release-group/${_release.rgid}';
    final episodes = List<Episode>.from(
      state.episodes.map(
        (e) => e.copyWith(album: state.series.title),
        // (e) => e.copyWith(album: state.series.title, image: state.series.image),
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background poster
                // backdropImage(context, state.background!),

                // Dark overlay
                Container(color: Colors.black.withValues(alpha: 0.65)),

                // Blur effect
                // BackdropFilter(
                //   filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), //12
                //   child: Container(
                //     color: Colors.black.withOpacity(0.2), // 0.2
                //   ),
                // ),
                SafeArea(
                  child: Focus(
                    canRequestFocus: false,
                    descendantsAreFocusable: true,
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          pinned: true,
                          leading: CircleButton.back(
                            onTap: () => Navigator.pop(context),
                          ),
                          title: Text(series.title),
                          actions: [
                            popupMenu(
                              context,
                              [
                                // PopupItem.play(
                                //   context,
                                //   (_) => _onPlay(context, state),
                                // ),
                                // PopupItem.shuffle(
                                //   context,
                                //   (_) => _onShufflePlay(context),
                                // ),
                                // PopupItem.download(
                                //   context,
                                //   (_) => _onDownload(context, state),
                                // ),
                                // PopupItem.playlistAppend(
                                //   context,
                                //   (_) => _onPlaylistAppend(context, state),
                                // ),
                                // PopupItem.divider(),
                                // PopupItem.link(
                                //   context,
                                //   'MusicBrainz Release',
                                //   (_) => launchUrl(Uri.parse(releaseUrl)),
                                // ),
                                // PopupItem.link(
                                //   context,
                                //   'MusicBrainz Release Group',
                                //   (_) => launchUrl(Uri.parse(releaseGroupUrl)),
                                // ),
                                PopupItem.divider(),
                                PopupItem.reload(
                                  context,
                                  (_) => reloadPage(context),
                                ),
                              ],
                              icon: null,
                              child: CircleButton.dropDown(),
                            ),
                          ],
                        ),
                        if (episodes.isNotEmpty) ...[
                          SliverTitle(
                            'Episodes (${episodes.length})',
                            style: AppTextStyle.musicRelatedTitle,
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
                    ),
                  ),
                ),
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
