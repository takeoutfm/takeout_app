import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/client.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/spiff/spiff_tracks.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';

typedef FetchSpiff = Future<void> Function(ClientCubit, {Duration? ttl});

class SpiffDetailsPage extends ClientPage<Spiff> {
  final FetchSpiff? fetch;
  final String? ref;

  SpiffDetailsPage({super.key, super.value, this.fetch, this.ref});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) async {
    await fetch?.call(context.client, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, Spiff state) {
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
                backdropImage(context, state.playlist.background ?? ''),

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
                          actions: [
                            popupMenu(
                              context,
                              [
                                PopupItem.play(
                                  context,
                                  (_) => _onPlay(context, state),
                                ),
                                // PopupItem.shuffle(
                                //   context,
                                //   (_) => _onShufflePlay(context),
                                // ),
                                // PopupItem.download(
                                //   context,
                                //       (_) => _onDownload(context, state),
                                // ),
                                // PopupItem.playlistAppend(
                                //   context,
                                //       (_) => _onPlaylistAppend(context, state),
                                // ),
                                // PopupItem.divider(),
                                // PopupItem.link(
                                //   context,
                                //   'MusicBrainz Release',
                                //       (_) => launchUrl(Uri.parse(releaseUrl)),
                                // ),
                                // PopupItem.link(
                                //   context,
                                //   'MusicBrainz Release Group',
                                //       (_) => launchUrl(Uri.parse(releaseGroupUrl)),
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
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsetsGeometry.all(20),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                // Movie content
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: releaseSmallCover(
                                        context,
                                        state.cover,
                                      ),
                                    ),

                                    const SizedBox(width: 20),

                                    // Movie details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.playlist.title,
                                            style:
                                                AppTextStyle.musicReleaseTitle,
                                          ),

                                          const SizedBox(height: 12),

                                          Text(
                                            state.creator ?? 'none',
                                            style: AppTextStyle.musicArtist
                                                .copyWith(
                                                  decoration: .underline,
                                                ),
                                          ),

                                          const SizedBox(height: 12),

                                          Wrap(
                                            children: [
                                              // Text(
                                              //   'no year',
                                              //   style: AppTextStyle.musicYear,
                                              // ),
                                              // SizedBox(width: 16),
                                              Text(
                                                context.strings.trackCount(
                                                  state.playlist.tracks.length,
                                                ),
                                                style: AppTextStyle
                                                    .musicTrackCount,
                                              ),
                                            ],
                                          ),

                                          // const SizedBox(height: 16),
                                          // Wrap(
                                          //   spacing: 8,
                                          //   runSpacing: 8,
                                          //   children: [
                                          //     MyChip(
                                          //       label: state.artist.genre ?? '',
                                          //       onPressed: () => _onGenre(
                                          //         context,
                                          //         state.artist.genre ?? '',
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () => _onPlay(context, state),
                                      label: Text('Play'),
                                      icon: Icon(Icons.play_arrow),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),

                                // Tracks
                                // const Text(
                                //   'Tracks',
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 24,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                //
                                // const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.50),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SpiffTracks(state),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //   if (state.similar.isNotEmpty) ...[
                        //     SliverTitle(
                        //       'Related',
                        //       style: AppTextStyle.musicRelatedTitle,
                        //     ),
                        //     SliverAlbumGrid(
                        //       state.similar,
                        //       padding: EdgeInsetsGeometry.only(
                        //         left: albumGridEdgeInset,
                        //         right: albumGridEdgeInset,
                        //         bottom: albumGridEdgeInset,
                        //       ),
                        //     ),
                        //   ],
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

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => AllArtistsGrid(genre: genre));
  }

  // void _onPlay(BuildContext context, ReleaseView view) {
  //   context.playlist.replace(
  //     _release.reference,
  //     creator: _release.creator,
  //     title: _release.name,
  //   );
  // }

  void _onPlay(BuildContext context, Spiff spiff) {
    // final offsets = context.read<OffsetCacheCubit>();
    if (spiff.isVideo) {
      final entry = spiff.playlist.tracks.first;
      // final pos = offsets.state.position(entry);
      context.showMovie(entry);
    } else {
      context.play(spiff);
    }
  }

  // void _onArtist(BuildContext context, Spiff spiff) {
  //   push(context, builder: (_) => ArtistDetailsPage(spiff.creator ?? ''));
  // }

  // void _onShufflePlay(BuildContext context) {
  //   context.playlist.replace(
  //     _release.reference,
  //     creator: _release.creator,
  //     title: _release.name,
  //     shuffle: true,
  //   );
  // }

  // void _onDownload(BuildContext context, ReleaseView view) {
  //   context.downloadRelease(view.release);
  // }
  //
  // void _onPlaylistAppend(BuildContext context, ReleaseView state) {
  //   showPlaylistAppend(context, state.release.reference);
  // }
}
