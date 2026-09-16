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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/widgets/style.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

class SpiffTracks extends StatelessWidget {
  final Spiff spiff;

  const SpiffTracks(this.spiff, {super.key});

  void _onTrack(BuildContext context, int index) {
    if (spiff.isMusic || spiff.isPodcast) {
      context.play(spiff.copyWith(index: index));
    } else if (spiff.isVideo) {
      final video = spiff.playlist.tracks[index];
      context.showMovie(VideoTrack.fromEntry(video));
    }
  }

  void _onArtist(BuildContext context, String? artist) {
    context.showArtist(artist ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final downloads = context.watch<DownloadCubit>();
        final trackCache = context.watch<TrackCacheCubit>();
        final children = <Widget>[];
        final tracks = spiff.playlist.tracks;
        for (var i = 0; i < spiff.length; i++) {
          final e = tracks[i];
          children.add(
            CoverTrackListTile.mediaTrack(
              context,
              e,
              onTap: () => _onTrack(context, i),
              onLongPress: () => _onArtist(context, spiff.creator),
              trailing: _trailing(downloads.state, trackCache.state, e),
              selected: i == spiff.index,
            ),
          );
          if (i + 1 != spiff.length) {
            children.add(Divider());
          }
        }
        return Column(crossAxisAlignment: .start, children: children);
      },
    );
  }

  Widget? _trailing(
    DownloadState downloads,
    TrackCacheState cache,
    Entry entry,
  ) {
    if (cache.contains(entry)) {
      return const Icon(iconsCached);
    }
    final progress = downloads.progress(entry);
    return progress != null
        ? CircularProgressIndicator(value: progress.value)
        : null;
  }
}
