// Copyright 2023 defsub
//
// This file is part of TakeoutFM.
//
// TakeoutFM is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// TakeoutFM is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with TakeoutFM.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/menu.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/art/scaffold.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'artists.dart';
import 'buttons.dart';
import 'nav.dart';
import 'style.dart';
import 'tiles.dart';

class ReleaseWidget extends ClientPage<ReleaseView> {
  final Release _release;

  ReleaseWidget(this._release, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.release(_release.id, ttl: ttl);
  }

  void _onArtist(BuildContext context, ReleaseView view) {
    push(context, builder: (_) => ArtistWidget(view.artist));
  }

  void _onPlay(BuildContext context) {
    context.playlist.replace(_release.reference,
        creator: _release.creator, title: _release.name);
  }

  void _onDownload(BuildContext context, ReleaseView view) {
    context.downloadRelease(view.release);
  }

  @override
  Widget page(BuildContext context, ReleaseView state) {
    final releaseUrl = 'https://musicbrainz.org/release/${_release.reid}';
    final releaseGroupUrl =
        'https://musicbrainz.org/release-group/${_release.rgid}';
    // cover images are 250x250 (or 500x500)
    // distort a bit to only take half the screen
    final screen = MediaQuery.of(context).size;
    final expandedHeight = screen.height / 2;
    return scaffold(context,
        image: _release.image,
        body: (_) => RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
                builder: (context, cacheState) {
              final isCached = cacheState.containsAll(state.tracks);
              return CustomScrollView(slivers: [
                SliverAppBar(
                  // floating: true,
                  // snap: false,
                  // backgroundColor: backgroundColor,
                  expandedHeight: expandedHeight,
                  actions: [
                    popupMenu(context, [
                      PopupItem.play(context, (_) => _onPlay(context)),
                      PopupItem.download(
                          context, (_) => _onDownload(context, state)),
                      PopupItem.divider(),
                      PopupItem.link(context, 'MusicBrainz Release',
                          (_) => launchUrl(Uri.parse(releaseUrl))),
                      PopupItem.link(context, 'MusicBrainz Release Group',
                          (_) => launchUrl(Uri.parse(releaseGroupUrl))),
                      PopupItem.divider(),
                      PopupItem.reload(context, (_) => reloadPage(context)),
                    ]),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                      // centerTitle: true,
                      // title: Text(release.name, style: TextStyle(fontSize: 15)),
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle
                      ],
                      background: Stack(fit: StackFit.expand, children: [
                        releaseSmallCover(context, _release.image),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.75),
                              end: Alignment(0.0, 0.0),
                              colors: <Color>[
                                Color(0x60000000),
                                Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: _playButton(context, isCached)),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: _downloadButton(context, state, isCached)),
                      ])),
                ),
                SliverToBoxAdapter(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                        child: Column(children: [
                          GestureDetector(
                              onTap: () => _onArtist(context, state),
                              child: _title(context)),
                          GestureDetector(
                              onTap: () => _onArtist(context, state),
                              child: _artist(context)),
                        ]))),
                SliverToBoxAdapter(child: _ReleaseTracksWidget(state)),
                if (state.similar.isNotEmpty)
                  SliverToBoxAdapter(
                    child: heading(context.strings.similarReleasesLabel),
                  ),
                if (state.similar.isNotEmpty) AlbumGridWidget(state.similar),
              ]);
            })));
  }

  Widget _title(BuildContext context) {
    return Text(_release.name,
        style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _artist(BuildContext context) {
    var artist = _release.artist;
    if (isNotNullOrEmpty(_release.date)) {
      artist = merge([artist, year(_release.date)]);
    }
    return Text(artist, style: Theme.of(context).textTheme.titleMedium!);
  }

  Widget _playButton(BuildContext context, bool isCached) {
    return isCached
        ? IconButton(
            icon: const Icon(Icons.play_arrow, size: 32),
            onPressed: () => _onPlay(context))
        : StreamingButton(onPressed: () => _onPlay(context));
  }

  Widget _downloadButton(
      BuildContext context, ReleaseView view, bool isCached) {
    return isCached
        ? IconButton(icon: const Icon(iconsDownloadDone), onPressed: () => {})
        : DownloadButton(onPressed: () => _onDownload(context, view));
  }
}

class _ReleaseTracksWidget extends StatelessWidget {
  final ReleaseView _view;

  const _ReleaseTracksWidget(this._view);

  void _onPlay(BuildContext context, int index) {
    context.playlist.replace(_view.release.reference,
        index: index,
        creator: _view.release.creator,
        title: _view.release.name);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final downloads = context.watch<DownloadCubit>();
      final trackCache = context.watch<TrackCacheCubit>();
      int discs = _view.discs;
      int d = 0;
      List<Widget> children = [];
      for (var i = 0; i < _view.tracks.length; i++) {
        final e = _view.tracks[i];
        if (discs > 1 && e.discNum != d) {
          if (e.discNum > 1) {
            children.add(const Divider());
          }
          children.add(smallHeading(
              context, context.strings.discLabel(e.discNum, discs)));
          d = e.discNum;
        }
        children.add(NumberedTrackListTile(e,
            onTap: () => _onPlay(context, i),
            trailing:
                _trailing(context, downloads.state, trackCache.state, e)));
      }
      return Column(children: children);
    });
  }

  Widget? _trailing(BuildContext context, DownloadState downloadState,
      TrackCacheState trackCache, Track t) {
    if (trackCache.contains(t)) {
      return const Icon(iconsCached);
    }
    final progress = downloadState.progress(t);
    return (progress != null)
        ? CircularProgressIndicator(value: progress.value)
        : null;
  }
}

class AlbumGridWidget extends StatelessWidget {
  final List<MediaAlbum> _albums;
  final bool subtitle;

  const AlbumGridWidget(this._albums, {super.key, this.subtitle = true});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.extent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: [
          ..._albums.map((a) => GestureDetector(
              onTap: () => _onTap(context, a),
              child: GridTile(
                footer: Material(
                    color: Colors.transparent,
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.vertical(
                    //         bottom: Radius.circular(4))),
                    clipBehavior: Clip.antiAlias,
                    child: GridTileBar(
                      backgroundColor: Colors.black26,
                      title: Text(a.album),
                      subtitle: subtitle ? Text(a.creator) : null,
                    )),
                child: gridCover(context, a.image),
              )))
        ]);
  }

  void _onTap(BuildContext context, MediaAlbum album) {
    push(context, builder: (context) {
      if (album is Release) {
        return ReleaseWidget(album);
      }
      throw UnimplementedError;
    });
  }
}

//
// class ReleaseGridWidget extends StatelessWidget {
//   final List<Release> _releases;
//   final bool subtitle;
//
//   ReleaseGridWidget(this._releases, {this.subtitle = true});
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverGrid.count(
//         crossAxisCount: 3,
//         crossAxisSpacing: 5,
//         mainAxisSpacing: 5,
//         children: [
//           ..._releases.map((r) => Container(
//               child: GestureDetector(
//                   onTap: () => _onTap(context, r),
//                   child: GridTile(
//                     footer: Material(
//                         color: Colors.transparent,
//                         // shape: RoundedRectangleBorder(
//                         //     borderRadius: BorderRadius.vertical(
//                         //         bottom: Radius.circular(4))),
//                         clipBehavior: Clip.antiAlias,
//                         child: GridTileBar(
//                           backgroundColor: Colors.black26,
//                           title: Text(r.name),
//                           subtitle: subtitle ? Text(r.artist) : null,
//                         )),
//                     child: releaseCover(r),
//                   ))))
//         ]);
//   }
//
//   void _onTap(BuildContext context, Release release) {
//     Navigator.push(context,
//         MaterialPageRoute(builder: (context) => ReleaseWidget(release)));
//   }
// }

class ReleaseListWidget extends StatelessWidget {
  final List<Release> _releases;

  const ReleaseListWidget(this._releases, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._releases.map((e) => ListTile(
          leading: tileCover(context, e.image),
          onTap: () => _onTap(context, e),
          // trailing: IconButton(
          //     icon: Icon(Icons.playlist_add),
          //     onPressed: () => _onAppend(e)),
          trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _onPlay(context, e)),
          title: Text(e.nameWithDisambiguation),
          subtitle: Text(year(e.date))))
    ]);
  }

  void _onTap(BuildContext context, Release release) {
    push(context, builder: (_) => ReleaseWidget(release));
  }

  void _onPlay(BuildContext context, Release release) {
    context.playlist.replace(release.reference,
        creator: release.creator, title: release.name);
  }
}
