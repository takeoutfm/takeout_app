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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/list.dart';
import 'package:takeout_watch/media.dart';
import 'package:takeout_watch/player.dart';
import 'package:takeout_watch/settings.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dialog.dart';

class PodcastsPage extends StatelessWidget {
  final HomeView state;

  const PodcastsPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final series = state.newSeries ?? [];

    return MediaGrid(series,
        title: context.strings.podcastsLabel,
        onTap: (context, entry) => _onSeries(context, entry as Series));
  }
}

void _onSeries(BuildContext context, Series series) {
  Navigator.push(
      context, CupertinoPageRoute<void>(builder: (_) => SeriesPage(series)));
}

class SeriesPage extends ClientPage<SeriesView> {
  final Series series;

  SeriesPage(this.series, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.series(series.id, ttl: ttl);
  }

  @override
  void reload(BuildContext context) {
    super.reload(context);
    // force reload offsets
    context.offsets.reload();
  }

  @override
  Widget page(BuildContext context, SeriesView state) {
    final offsets = context.watch<OffsetCacheCubit>().state;
    final episodes = state.episodes;
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: RotaryList<Episode>(episodes,
                title: state.series.title,
                subtitle: state.series.creator,
                tileBuilder: (context, episode) => EpisodeTile(episode,
                    onTap: onEpisode,
                    onLongPress: onDownload,
                    offsets: offsets))));
  }

  void onEpisode(BuildContext context, Episode episode) {
    context.playlist.replace(episode.reference,
        mediaType: MediaType.podcast,
        creator: episode.creator,
        title: episode.title);
    showPlayer(context);
  }

  void onDownload(BuildContext context, Episode episode) {
    confirmDialog(context,
            title: context.strings.confirmDownload, body: episode.title)
        .then((confirmed) {
      if (confirmed != null && confirmed) {
        context.downloadEpisode(episode);
      }
    });
  }
}

typedef EpisodeCallback = void Function(BuildContext, Episode);

class EpisodeTile extends StatelessWidget {
  final Episode episode;
  final EpisodeCallback onTap;
  final EpisodeCallback? onLongPress;
  final OffsetCacheState offsets;

  const EpisodeTile(this.episode,
      {required this.onTap,
      required this.offsets,
      this.onLongPress,
      super.key});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final date = DateTime.parse(episode.date);
    children.add(Text(timeago.format(date),
        style: Theme.of(context).listTileTheme.subtitleTextStyle));
    final remaining = offsets.remaining(episode);
    if (remaining != null) {
      children.add(LinearPercentIndicator(
          lineHeight: 20.0,
          progressColor: Colors.blueAccent,
          backgroundColor: Colors.grey.shade800,
          barRadius: const Radius.circular(10),
          center: Text('${remaining.inHoursMinutes} remaining',
              style: Theme.of(context).listTileTheme.subtitleTextStyle),
          // TODO intl
          percent: offsets.value(episode) ?? 0.0));
    }
    final enableStreaming = allowStreaming(context);
    final enableDownload = allowDownload(context);
    return ListTile(
        enabled: enableStreaming,
        onTap: () => enableStreaming ? onTap(context, episode) : null,
        onLongPress: () =>
            enableDownload ? onLongPress?.call(context, episode) : null,
        title: Text(episode.title),
        subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.center, children: children));
  }
}
