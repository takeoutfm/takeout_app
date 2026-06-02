import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/artists.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/music/artist_details.dart';
import 'package:takeout_mobile/pages/music/release_tracks.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';
import 'package:url_launcher/url_launcher.dart';

class ReleaseDetailsPage extends ClientPage<ReleaseView> {
  final Release _release;

  ReleaseDetailsPage(this._release, {super.key});

  Release get release => _release;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.release(_release.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ReleaseView state) {
    final releaseUrl = 'https://musicbrainz.org/release/${_release.reid}';
    final releaseGroupUrl =
        'https://musicbrainz.org/release-group/${_release.rgid}';
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
                backdropImage(context, state.background ?? ''),

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
                        SliverMenuBar(
                          items: [
                            PopupItem.play(
                              context,
                              (_) => _onPlay(context, state),
                            ),
                            PopupItem.shuffle(
                              context,
                              (_) => _onShufflePlay(context),
                            ),
                            PopupItem.download(
                              context,
                              (_) => _onDownload(context, state),
                            ),
                            PopupItem.playlistAppend(
                              context,
                              (_) => _onPlaylistAppend(context, state),
                            ),
                            PopupItem.divider(),
                            PopupItem.link(
                              context,
                              'MusicBrainz Release',
                              (_) => launchUrl(Uri.parse(releaseUrl)),
                            ),
                            PopupItem.link(
                              context,
                              'MusicBrainz Release Group',
                              (_) => launchUrl(Uri.parse(releaseGroupUrl)),
                            ),
                            PopupItem.divider(),
                            PopupItem.reload(
                              context,
                              (_) => reloadPage(context),
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
                                        release.image,
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
                                            release.name,
                                            style:
                                                AppTextStyle.musicReleaseTitle,
                                          ),

                                          const SizedBox(height: 12),

                                          GestureDetector(
                                            onTap: () =>
                                                _onArtist(context, state),
                                            child: Text(
                                              release.artist,
                                              style: AppTextStyle.musicArtist
                                                  .copyWith(
                                                    decoration: .underline,
                                                  ),
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          Wrap(
                                            children: [
                                              Text(
                                                '${release.year}',
                                                style: AppTextStyle.musicYear,
                                              ),
                                              SizedBox(width: 16),
                                              Text(
                                                context.strings.trackCount(
                                                  state.tracks.length,
                                                ),
                                                style: AppTextStyle
                                                    .musicTrackCount,
                                              ),
                                              SizedBox(width: 16),
                                              Text(
                                                context.strings.discCount(
                                                  state.discs,
                                                ),
                                                style:
                                                    AppTextStyle.musicDiscCount,
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              MyChip(
                                                label: state.artist.genre ?? '',
                                                onPressed: () => _onGenre(
                                                  context,
                                                  state.artist.genre ?? '',
                                                ),
                                              ),
                                            ],
                                          ),
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
                                  child: ReleaseTracks(state),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.similar.isNotEmpty) ...[
                          SliverTitle(
                            'Related',
                            style: AppTextStyle.musicRelatedTitle,
                          ),
                          SliverAlbumGrid(
                            state.similar,
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

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => AllArtistsGrid(genre: genre));
  }

  void _onPlay(BuildContext context, ReleaseView view) {
    context.playlist.replace(
      _release.reference,
      creator: _release.creator,
      title: _release.name,
    );
  }

  void _onArtist(BuildContext context, ReleaseView view) {
    push(context, builder: (_) => ArtistDetailsPage(view.artist));
  }

  void _onShufflePlay(BuildContext context) {
    context.playlist.replace(
      _release.reference,
      creator: _release.creator,
      title: _release.name,
      shuffle: true,
    );
  }

  void _onDownload(BuildContext context, ReleaseView view) {
    context.downloadRelease(view.release);
  }

  void _onPlaylistAppend(BuildContext context, ReleaseView state) {
    showPlaylistAppend(context, state.release.reference);
  }
}
