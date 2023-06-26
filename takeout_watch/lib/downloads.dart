// Copyright 2023 defsub
//
// This file is part of Takeout.
//
// Takeout is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/settings.dart';

import 'dialog.dart';
import 'list.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpiffCacheCubit, SpiffCacheState>(
        builder: (context, state) {
      final spiffs = state.spiffs ?? [];
      return Scaffold(
          body: RotaryList<Spiff>(List.from(spiffs),
              tileBuilder: spiffTile, title: context.strings.downloadsLabel));
    });
  }

  Widget spiffTile(BuildContext context, Spiff spiff) {
    return Builder(builder: (context) {
      final trackCache = context.watch<TrackCacheCubit>();
      final downloads = context.watch<DownloadCubit>();

      final children = <Widget>[];

      final creator = spiff.playlist.creator;
      if (creator != null) {
        children.add(Text(creator,
            style: context.listTileTheme.subtitleTextStyle));
      }

      final count = trackCache.state.count(spiff.playlist.tracks);
      if (count < spiff.playlist.tracks.length) {
        for (var t in spiff.playlist.tracks) {
          final progress = downloads.state.progress(t);
          // TODO seen this w/ stuck progress a few times
          // print('${progress?.value} $count ${spiff.playlist.tracks.length} ${trackCache.state.containsAll(spiff.playlist.tracks)}');
          if (progress != null && progress.value < 1.0) {
            children.add(LinearPercentIndicator(
                lineHeight: 20.0,
                progressColor: Colors.blueAccent,
                backgroundColor: Colors.grey.shade800,
                barRadius: const Radius.circular(10),
                center: spiff.playlist.tracks.length > 1
                    ? Text('$count / ${spiff.playlist.tracks.length}')
                    : null,
                percent: progress.value));
          }
        }
      }

      return ListTile(
          isThreeLine: children.length > 1,
          title: Text(spiff.playlist.title),
          subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
          onTap: () => onSpiff(context, spiff),
          onLongPress: () => onDelete(context, spiff));
    });
  }

  void onSpiff(BuildContext context, Spiff spiff) {
    if (context.trackCache.state.containsAll(spiff.playlist.tracks) == false) {
      if (allowDownload(context)) {
        confirmDialog(context, title: context.strings.confirmDownload)
            .then((confirmed) {
          if (confirmed != null && confirmed) {
            // resume download
            context.download(spiff);
          } else {
            // just play
            context.play(spiff);
            context.showPlayer(context);
          }
        });
      }
    } else {
      context.play(spiff);
      context.showPlayer(context);
    }
  }

  void onDelete(BuildContext context, Spiff spiff) {
    confirmDialog(context,
            title: context.strings.confirmDelete, body: spiff.title)
        .then((confirmed) {
      if (confirmed != null && confirmed) {
        context.remove(spiff);
      }
    });
  }
}
