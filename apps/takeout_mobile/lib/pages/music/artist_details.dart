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
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtistDetailsPage extends ClientPage<ArtistView> {
  final Artist _artist;

  ArtistDetailsPage(this._artist, {super.key});

  Artist get artist => _artist;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.artist(_artist.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ArtistView state) {
    final artistUrl = 'https://musicbrainz.org/artist/${_artist.arid}';
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return SliverStack(
              backdrop: state.background,
              slivers: [
                SliverMenuBar(
                  items: [
                    PopupItem.shuffle(context, (_) => _onShuffle(context)),
                    PopupItem.radio(context, (_) => _onRadio(context)),
                    PopupItem.playlistAppend(
                      context,
                      (_) => _onPlaylistAppend(context),
                    ),
                    PopupItem.divider(),
                    PopupItem.singles(context, (_) => _onSingles(context)),
                    PopupItem.popular(context, (_) => _onPopular(context)),
                    PopupItem.divider(),
                    if (_artist.genre != null)
                      PopupItem.genre(
                        context,
                        _artist.genre!.titleCased,
                        (_) => _onGenre(context, _artist.genre!),
                      ),
                    if (_artist.area != null)
                      PopupItem.area(
                        context,
                        _artist.area!,
                        (_) => _onArea(context, _artist.area!),
                      ),
                    PopupItem.divider(),
                    PopupItem.link(
                      context,
                      'MusicBrainz Artist',
                      (_) => launchUrl(Uri.parse(artistUrl)),
                    ),
                    PopupItem.divider(),
                    // PopupItem.wantList(context, (_) => _onWantList(context)),
                    PopupItem.reload(context, (_) => reloadPage(context)),
                  ],
                ),
                SliverBox(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const posterWidth = 300.0;
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
                                child: _artistPoster(context, state),
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
                                    children: [_artistDetails(context, state)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // tall view
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _artistPoster(context, state),
                          const SizedBox(height: 16),
                          _artistDetails(context, state),
                        ],
                      );
                    },
                  ),
                ),
                if (state.releases.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.releasesLabel,
                    style: context.header2,
                  ),
                  SliverAlbumGrid(
                    state.releases,
                    padding: EdgeInsetsGeometry.only(
                      left: albumGridEdgeInset,
                      right: albumGridEdgeInset,
                      bottom: albumGridEdgeInset,
                    ),
                  ),
                ],
                if (state.similar.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.relatedLabel,
                    style: context.header2,
                  ),
                  SliverArtistGrid(
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

  Widget _artistPoster(BuildContext context, ArtistView state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: artistSmallPoster(context, state.image ?? ''),
    );
  }

  Widget _artistDetails(BuildContext context, ArtistView state) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(artist.name, style: context.header1),
        const SizedBox(height: 12),
        Wrap(
          children: [
            Text('${parseYear(artist.date ?? '')}', style: context.body),
            if (artist.area != null) ...[
              SizedBox(width: 16),
              GestureDetector(
                onTap: () => _onArea(context, artist.area!),
                child: Text('${artist.area}', style: context.bodyLink),
              ),
            ],
          ],
        ),
        if (state.artist.genre?.isNotEmpty ?? false) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MyChip(
                label: state.artist.genre?.titleCased ?? '',
                onTap: () => _onGenre(context, state.artist.genre ?? ''),
              ),
              MyChip(
                label: context.strings.singlesLabel,
                onTap: () => _onSingles(context),
              ),
              MyChip(
                label: context.strings.popularLabel,
                onTap: () => _onPopular(context),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => AllArtistsGrid(genre: genre));
  }

  void _onRadio(BuildContext context) {
    pushSpiff(
      title: context.strings.radioLabel,
      ref: '/music/artists/${_artist.id}/radio',
      context,
      (client, {Duration? ttl}) =>
          client.artistRadio(_artist.id, ttl: Duration.zero),
    );
  }

  void _onShuffle(BuildContext context) {
    pushSpiff(
      title: context.strings.shuffleLabel,
      ref: '/music/artists/${_artist.id}/shuffle',
      context,
      (client, {Duration? ttl}) =>
          client.artistPlaylist(_artist.id, ttl: Duration.zero),
    );
  }

  void _onSingles(BuildContext context) {
    pushSpiff(
      title: context.strings.singlesLabel,
      ref: '/music/artists/${_artist.id}/singles',
      context,
      (client, {Duration? ttl}) =>
          client.artistSinglesPlaylist(_artist.id, ttl: ttl),
    );
  }

  void _onPopular(BuildContext context) {
    pushSpiff(
      title: context.strings.popularLabel,
      ref: '/music/artists/${_artist.id}/popular',
      context,
      (client, {Duration? ttl}) =>
          client.artistPopularPlaylist(_artist.id, ttl: ttl),
    );
  }

  void _onArea(BuildContext context, String area) {
    push(context, builder: (_) => AllArtistsGrid(area: area));
  }

  // void _onWantList(BuildContext context) {
  //   push(context, builder: (_) => ArtistWantListWidget(_artist));
  // }

  void _onPlaylistAppend(BuildContext context) {
    final ref = '/music/artists/${_artist.id}/playlist';
    showPlaylistAppend(context, ref);
  }
}
