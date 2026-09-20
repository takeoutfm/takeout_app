// Copyright 2026 defsub
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

import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_mobile/widgets/style.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

class SliverTrackList extends StatelessWidget {
  final List<Track> _tracks;

  const SliverTrackList(this._tracks, {super.key});

  List<Track> get tracks => _tracks;

  void _onPlay(BuildContext context, int index) {
    // TODO need to create local spiff to play not this older code
    // context.playlist.replace(
    //   _view.release.reference,
    //   index: index,
    //   creator: _view.release.creator,
    //   title: _view.release.name,
    // );
  }

  // void _onLongPress(BuildContext context, Track t, RelativeRect pos) {
  //   showPopupMenu(context, pos, [
  //     PopupItem.trackPlaylist(context, (_) {
  //       pushSpiff(
  //         ref: '/music/tracks/${t.id}/playlist',
  //         context,
  //         (client, {Duration? ttl}) =>
  //             client.trackPlaylist('${t.id}', ttl: Duration.zero),
  //       );
  //     }),
  //   ]);
  // }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final downloads = context.watch<DownloadCubit>();
        final trackCache = context.watch<TrackCacheCubit>();
        List<Widget> children = [];
        for (var i = 0; i < tracks.length; i++) {
          final e = tracks[i];
          children.add(
            // GestureDetector(
            //   onDoubleTapDown: (d) {
            //     final offset = d.globalPosition;
            //     final pos = RelativeRect.fromLTRB(
            //       offset.dx,
            //       offset.dy,
            //       MediaQuery.of(context).size.width - offset.dx,
            //       MediaQuery.of(context).size.height - offset.dy,
            //     );
            //     _onLongPress(context, e, pos);
            //   },
            DpadFocusable(
              onSelect: () => _onPlay(context, i),
              child: CoverTrackListTile.track(
                context,
                e,
                onTap: () => _onPlay(context, i),
                trailing: _trailing(
                  context,
                  downloads.state,
                  trackCache.state,
                  e,
                ),
              ),
            ),
          );
          // if (i + 1 != tracks.length) {
          //   children.add(Divider());
          // }
        }
        return SliverList.builder(
          itemCount: children.length,
          itemBuilder: (context, i) => children[i],
        );
      },
    );
  }

  Widget? _trailing(
    BuildContext context,
    DownloadState downloadState,
    TrackCacheState trackCache,
    Track t,
  ) {
    if (trackCache.contains(t)) {
      return const Icon(iconsCached);
    }
    final progress = downloadState.progress(t);
    return (progress != null)
        ? CircularProgressIndicator(value: progress.value)
        : null;
  }
}
