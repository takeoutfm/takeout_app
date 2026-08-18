import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/music/artist_details.dart';
import 'package:takeout_mobile/pages/music/release_tracks.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
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
            return SliverStack(
              backdrop: state.background ?? '',
              slivers: [
                SliverMenuBar(
                  // title: '${release.name} (${release.year}) by ${release.artist}',
                  items: [
                    PopupItem.play(context, (_) => _onPlay(context, state)),
                    PopupItem.shuffle(context, (_) => _onShufflePlay(context)),
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
                    PopupItem.reload(context, (_) => reloadPage(context)),
                  ],
                ),
                SliverBox(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const posterWidth = 223.0;
                      const minDetailsWidth = 300.0;
                      final hasRoom =
                          constraints.maxWidth >= posterWidth + minDetailsWidth;
                      if (hasRoom) {
                        // wide view
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: .stretch,
                            children: [
                              SizedBox(
                                width: posterWidth,
                                child: _releaseCover(context, state),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    mainAxisAlignment: .spaceBetween,
                                    children: [
                                      _releaseDetails(context, state),
                                      SizedBox(height: 16),
                                      _playButtons(context, state),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // tall view
                      return Column(
                        crossAxisAlignment: .start,
                        children: [
                          _releaseCover(context, state),
                          const SizedBox(height: 16),
                          _playButtons(context, state),
                          const SizedBox(height: 16),
                          _releaseDetails(context, state, center: false),
                        ],
                      );
                    },
                  ),
                ),
                SliverBox(
                  padding: EdgeInsetsGeometry.only(left: 20, right: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ReleaseTracks(state),
                  ),
                ),
                if (state.similar.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.relatedLabel,
                    style: context.header2,
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
            );
          },
        ),
      ),
    );
  }

  Widget _playButtons(BuildContext context, ReleaseView state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          autofocus: true,
          onPressed: () => _onPlay(context, state),
          label: Text(context.strings.playLabel),
          icon: Icon(Icons.play_arrow),
        ),
        FilledButton.icon(
          onPressed: () => _onShufflePlay(context),
          label: Text(context.strings.shuffleLabel),
          icon: Icon(Icons.shuffle),
        ),
      ],
    );
  }

  Widget _releaseCover(BuildContext context, ReleaseView state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: releaseSmallCover(context, release.image),
    );
  }

  Widget _releaseDetails(BuildContext context, ReleaseView state, {bool center = false}) {
    return Column(
      crossAxisAlignment: center ? .center : .start,
      children: [
        Text(release.name, style: context.header1),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _onArtist(context, state),
          child: Text(release.artist, style: context.bodyLink),
        ),
        const SizedBox(height: 12),
        Wrap(
          children: [
            Text('${release.year}', style: context.body),
            SizedBox(width: 16),
            Text(
              context.strings.trackCount(state.tracks.length),
              style: context.body,
            ),
            SizedBox(width: 16),
            Text(context.strings.discCount(state.discs), style: context.body),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MyChip(
              label: state.artist.genre?.titleCased ?? '',
              onTap: () => _onGenre(context, state.artist.genre ?? ''),
            ),
          ],
        ),
      ],
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
