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
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/util.dart';
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
        final offsets = context.watch<OffsetCacheCubit>();
        final children = <Widget>[];
        final tracks = spiff.playlist.tracks;
        final sameArtwork = tracks.every((e) => e.image == tracks.first.image);
        for (var i = 0; i < spiff.length; i++) {
          final e = tracks[i];
          final subChildren = _subtitle(trackCache.state, offsets.state, e);
          final subtitle = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: subChildren,
          );
          final isThreeLine = subChildren.length > 1 || spiff.isPodcast;
          children.add(
            CoverTrackListTile.mediaTrack(context, e,
              // isThreeLine: isThreeLine,
              onTap: () => _onTrack(context, i),
              onLongPress: () => _onArtist(context, spiff.creator),
              // leading: _leading(context, e, sameArtwork),
              trailing: _trailing(downloads.state, trackCache.state, e),
              // subtitle: subtitle,
              selected: i == spiff.index,
              // title: Text(e.title),
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

  Widget? _leading(BuildContext context, Entry entry, bool sameArtwork) {
    // final pos = snapshot.position(entry);
    // final end = snapshot.duration(entry);
    // if (pos != null && end != null) {
    //   final value = pos.inSeconds.toDouble() / end.inSeconds.toDouble();
    //   return CircularProgressIndicator(value: value);
    // } else {
    return sameArtwork ? null : tileCover(context, entry.image);
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

  List<Widget> _subtitle(
    TrackCacheState state,
    OffsetCacheState offsets,
    Entry entry,
  ) {
    final children = <Widget>[];
    if (spiff.isMusic) {
      if (entry.creator != spiff.playlist.creator) {
        children.add(Text(entry.creator, overflow: TextOverflow.ellipsis));
      }
      children.add(
        Text(
          merge([entry.album, if (state.contains(entry)) storage(entry.size)]),
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      final duration = offsets.remaining(entry);
      if (duration != null) {
        if (spiff.isPodcast || spiff.isVideo) {
          final value = offsets.value(entry);
          if (value != null) {
            children.add(LinearProgressIndicator(value: value));
          }
        }
      }
      children.add(
        RelativeDateWidget.from(
          spiffDate(spiff, entry: entry),
          prefix: entry.creator,
          suffix: state.contains(entry) ? storage(entry.size) : '',
        ),
      );
    }
    return children;
  }
}
