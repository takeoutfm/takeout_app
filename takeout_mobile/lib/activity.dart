// Copyright 2024 defsub
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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/stats.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/menu.dart';

import 'nav.dart';
import 'style.dart';
import 'tiles.dart';

class TrackStatsWidget extends ClientPage<TrackStatsView> {
  TrackStatsWidget({super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.trackStats(ttl: ttl, interval: context.stats.state.interval);
  }

  @override
  Widget page(BuildContext context, TrackStatsView state) {
    final selected = context.watch<StatsCubit>().state;

    final types = SegmentedButton<StatsType>(segments: [
      ButtonSegment<StatsType>(
        value: StatsType.artist,
        label: Text(context.strings.artistsLabel),
      ),
      ButtonSegment<StatsType>(
        value: StatsType.release,
        label: Text(context.strings.releasesLabel),
      ),
      ButtonSegment<StatsType>(
        value: StatsType.track,
        label: Text(context.strings.tracksLabel),
      ),
    ], selected: {
      selected.type
    }, onSelectionChanged: (selected) => context.stats.type(selected.first));

    final intervals = SegmentedButton<IntervalType>(
        segments: [
          ButtonSegment<IntervalType>(
            value: IntervalType.recent,
            label: Text(context.strings.recentLabel),
          ),
          ButtonSegment<IntervalType>(
            value: IntervalType.lastweek,
            label: Text(context.strings.lastWeek),
          ),
          ButtonSegment<IntervalType>(
            value: IntervalType.lastmonth,
            label: Text(context.strings.lastMonth),
          ),
          ButtonSegment<IntervalType>(
            value: IntervalType.month,
            label: Text(context.strings.thisMonth),
          ),
        ],
        selected: {
          selected.interval
        },
        onSelectionChanged: (selected) {
          context.stats.interval(selected.first);
          reload(context);
        });

    return Scaffold(
      appBar: AppBar(title: Text(context.strings.activityLabel), actions: [
        popupMenu(context, [
          PopupItem.play(context, (_) => _onPlay(context, state.tracks)),
          PopupItem.shuffle(
              context, (_) => _onPlay(context, state.tracks, shuffle: true)),
          PopupItem.reload(context, (_) => reloadPage(context)),
        ])
      ]),
      body: RefreshIndicator(
          onRefresh: () => reloadPage(context),
          child: Column(children: [
            types,
            intervals,
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
              children: [
                if (selected.type == StatsType.artist)
                  _ActivityArtistListWidget(
                    state.artists,
                  ),
                if (selected.type == StatsType.release)
                  _ActivityReleaseListWidget(state.releases),
                if (selected.type == StatsType.track)
                  _ActivityTrackListWidget(state.tracks, showCounts: true)
              ],
            )))
          ])),
    );
  }
}

class TrackHistoryWidget extends ClientPage<TrackHistoryView> {
  TrackHistoryWidget({super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.recentTracks(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TrackHistoryView state) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.recentlyPlayed), actions: [
        popupMenu(context, [
          PopupItem.play(context, (_) => _onPlay(context, state.tracks)),
          PopupItem.shuffle(
              context, (_) => _onPlay(context, state.tracks, shuffle: true)),
          PopupItem.reload(context, (_) => reloadPage(context)),
        ])
      ]),
      body: RefreshIndicator(
          onRefresh: () => reloadPage(context),
          child: SingleChildScrollView(
              child: Column(
            children: [
              _ActivityTrackListWidget(state.tracks),
            ],
          ))),
    );
  }
}

class _ActivityTrackListWidget extends StatelessWidget {
  final List<ActivityTrack> tracks;
  final bool showCounts;

  const _ActivityTrackListWidget(this.tracks, {this.showCounts = false});

  void _onDoubleTap(BuildContext context, Track t, RelativeRect pos) {
    showPopupMenu(context, pos, [
      PopupItem.trackPlaylist(context, (_) {
        pushSpiff(
            ref: '/music/tracks/${t.id}/playlist',
            context,
            (client, {Duration? ttl}) =>
                client.trackPlaylist('${t.id}', ttl: Duration.zero));
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final downloads = context.watch<DownloadCubit>();
      final trackCache = context.watch<TrackCacheCubit>();
      List<Widget> children = [];
      for (var i = 0; i < tracks.length; i++) {
        final e = tracks[i];
        children.add(GestureDetector(
            onDoubleTapDown: (d) {
              final offset = d.globalPosition;
              final pos = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                MediaQuery.of(context).size.width - offset.dx,
                MediaQuery.of(context).size.height - offset.dy,
              );
              _onDoubleTap(context, e.track, pos);
            },
            child: CoverTrackListTile.mediaTrack(context, e.track,
                onTap: () => _onPlay(context, tracks, index: i),
                trailing:
                    _trailing(context, downloads.state, trackCache.state, e))));
      }
      return Column(children: children);
    });
  }

  Widget? _trailing(BuildContext context, DownloadState downloadState,
      TrackCacheState trackCache, ActivityTrack t) {
    if (showCounts) {
      return Text('${t.count}', style: Theme.of(context).textTheme.bodyLarge);
    }
    if (trackCache.contains(t.track)) {
      return const Icon(iconsCached);
    }
    final progress = downloadState.progress(t.track);
    return (progress != null)
        ? CircularProgressIndicator(value: progress.value)
        : null;
  }
}

class _ActivityArtistListWidget extends StatelessWidget {
  final List<ActivityArtist> artists;

  const _ActivityArtistListWidget(this.artists);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var i = 0; i < artists.length; i++) {
      final a = artists[i];
      children.add(GestureDetector(
          child: ArtistListTile(context, a.artist.name,
              onTap: () {},
              trailing: Text('${a.count}',
                  style: Theme.of(context).textTheme.bodyLarge))));
    }
    return Column(children: children);
  }
}

class _ActivityReleaseListWidget extends StatelessWidget {
  final List<ActivityRelease> releases;

  const _ActivityReleaseListWidget(this.releases);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var i = 0; i < releases.length; i++) {
      final r = releases[i];
      children.add(GestureDetector(
          child: AlbumListTile(
              context, r.release.artist, r.release.album, r.release.image,
              onTap: () {},
              trailing: Text('${r.count}',
                  style: Theme.of(context).textTheme.bodyLarge))));
    }
    return Column(children: children);
  }
}

void _onPlay(BuildContext context, List<ActivityTrack> tracks,
    {int index = 0, bool shuffle = false}) {
  final mediaTracks = tracks.map((e) => e.track);
  final spiff = Spiff.fromMediaTracks(mediaTracks,
      title: context.strings.recentlyPlayed, index: index);
  context.play(shuffle ? spiff.shuffle() : spiff);
}
