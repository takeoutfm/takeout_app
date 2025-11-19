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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/nav.dart';
import 'package:takeout_watch/pages/media.dart';
import 'package:takeout_watch/pages/settings.dart';
import 'package:takeout_watch/widgets/dialog.dart';
import 'package:takeout_watch/widgets/list.dart';

class MusicPage extends StatelessWidget {
  final HomeView state;

  const MusicPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Release> releases;
    switch (context.selectedMediaType.state.musicType) {
      case MusicType.added:
        releases = state.added;
      default:
        releases = state.released;
    }
    return MediaPage(releases,
        title: context.strings.musicLabel,
        onLongPress: (context, entry) => _onDownload(context, entry as Release),
        onTap: (context, entry) => _onRelease(context, entry as Release));
  }
}

class ArtistsPage extends ClientPage<ArtistsView> {
  ArtistsPage({super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.artists(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ArtistsView state) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () => reloadPage(context),
      child: RotaryList<Artist>(state.artists,
          tileBuilder: artistTile, title: context.strings.artistsLabel),
    ));
  }

  Widget artistTile(BuildContext context, Artist artist) {
    return ListTile(
        title: Text(artist.name), onTap: () => onArtist(context, artist));
  }

  void onArtist(BuildContext context, Artist artist) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => ArtistPage(artist)));
  }
}

class ArtistPage extends ClientPage<ArtistView> {
  final Artist artist;

  ArtistPage(this.artist, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.artist(artist.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ArtistView state) {
    final releases = state.releases;
    return MediaPage(releases,
        title: state.artist.name,
        onLongPress: (context, entry) => _onDownload(context, entry as Release),
        onTap: (context, entry) => _onRelease(context, entry as Release));
  }
}

class ReleasePage extends ClientPage<ReleaseView> {
  final Release release;

  ReleasePage(this.release, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.release(release.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ReleaseView state) {
    final tracks = state.tracks;
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: RotaryList<Track>(tracks,
                title: state.release.name,
                subtitle: state.release.artist,
                tileBuilder: trackTile)));
  }

  Widget trackTile(BuildContext context, Track t) {
    Text? subtitle;
    if (t.trackArtist != release.artist) {
      subtitle = Text(t.trackArtist);
    }
    final enableStreaming = allowStreaming(context);
    return ListTile(
        enabled: enableStreaming,
        // leading: Text('${t.trackNum}.',
        //     style: context.textTheme.bodySmall),
        title: Text(t.title),
        subtitle: subtitle,
        onTap: () => onTrack(context, t));
  }

  void onTrack(BuildContext context, Track t) {
    context.playlist.replace(
      release.reference,
      index: t.trackIndex,
      creator: release.creator,
      title: release.name,
    );
    context.showPlayer(context);
  }
}

void _onRelease(BuildContext context, Release release) {
  Navigator.push(
      context, CupertinoPageRoute<void>(builder: (_) => ReleasePage(release)));
}

void _onDownload(BuildContext context, Release release) {
  if (allowDownload(context)) {
    confirmDialog(context,
            title: context.strings.confirmDownload, body: release.name)
        .then((confirmed) {
      if (confirmed != null && confirmed) {
        final context = globalAppKey.currentContext;
        if (context != null && context.mounted) {
          context.downloadRelease(release);
        }
      }
    });
  }
}
