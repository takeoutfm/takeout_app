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
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/menu.dart';

import 'nav.dart';
import 'style.dart';
import 'tiles.dart';

enum ActivityTracksType { popular, recent }

class PopularTracksWidget extends _ActivityTracksWidget {
  PopularTracksWidget({super.key}) : super(ActivityTracksType.popular);
}

class RecentTracksWidget extends _ActivityTracksWidget {
  RecentTracksWidget({super.key}) : super(ActivityTracksType.recent);
}

class _ActivityTracksWidget extends ClientPage<ActivityTracks> {
  final ActivityTracksType type;

  _ActivityTracksWidget(this.type, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    if (type == ActivityTracksType.popular) {
      context.client.popularTracks(ttl: ttl);
    } else if (type == ActivityTracksType.recent) {
      context.client.recentTracks(ttl: ttl);
    }
  }

  @override
  Widget page(BuildContext context, ActivityTracks state) {
    final title = switch (type) {
      ActivityTracksType.popular => context.strings.popularTracks,
      ActivityTracksType.recent => context.strings.recentlyPlayed,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [
        popupMenu(context, [
          PopupItem.play(context, (_) => _onPlay(context, type, state)),
          PopupItem.shuffle(
              context, (_) => _onPlay(context, type, state, shuffle: true)),
          PopupItem.reload(context, (_) => reloadPage(context)),
        ])
      ]),
      body: RefreshIndicator(
          onRefresh: () => reloadPage(context),
          child: SingleChildScrollView(
              child: Column(
            children: [
              _ActivityTrackListWidget(state, type),
            ],
          ))),
    );
  }
}

class _ActivityTrackListWidget extends StatelessWidget {
  final ActivityTracks _view;
  final ActivityTracksType _type;

  const _ActivityTrackListWidget(this._view, this._type);

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
      for (var i = 0; i < _view.tracks.length; i++) {
        final e = _view.tracks[i];
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
                onTap: () => _onPlay(context, _type, _view, index: i),
                trailing: _trailing(
                    context, downloads.state, trackCache.state, _type, e))));
      }
      return Column(children: children);
    });
  }

  Widget? _trailing(BuildContext context, DownloadState downloadState,
      TrackCacheState trackCache, ActivityTracksType type, ActivityTrack t) {
    if (type == ActivityTracksType.popular) {
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

void _onPlay(
    BuildContext context, ActivityTracksType type, ActivityTracks state,
    {int index = 0, bool shuffle = false}) {
  final tracks = state.tracks.map((e) => e.track);
  final title = switch (type) {
    ActivityTracksType.popular => context.strings.popularTracks,
    ActivityTracksType.recent => context.strings.recentlyPlayed,
  };
  final spiff = Spiff.fromMediaTracks(tracks, title: title, index: index);
  context.play(shuffle ? spiff.shuffle() : spiff);
}
