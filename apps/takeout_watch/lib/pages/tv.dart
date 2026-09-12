// Copyright 2025 defsub
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
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/play_video.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/pages/media.dart';
import 'package:takeout_watch/pages/settings.dart';
import 'package:takeout_watch/widgets/list.dart';

class ShowsPage extends ClientPage<TVShowsView> {
  ShowsPage({super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.shows(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVShowsView state) {
    return MediaPage(
      state.series,
      title: context.strings.showsLabel,
      onTap: (context, entry) => _onShow(context, entry as TVSeries),
    );
  }

  void _onShow(BuildContext context, TVSeries series) {
    Navigator.push(
      context,
      CupertinoPageRoute<void>(builder: (_) => TVSeriesPage(series)),
    );
  }
}

class TVSeriesPage extends ClientPage<TVSeriesView> {
  final TVSeries series;

  TVSeriesPage(this.series, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvSeries(series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVSeriesView state) {
    final subtitle = merge([
      state.series.rating,
      '${parseYear(state.series.date)}',
      state.series.vote,
    ]);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: RotaryList<TVEpisode>(
          state.episodes,
          title: state.series.name,
          subtitle: subtitle,
          tileBuilder: (context, entry) => tvEpisodeTile(context, entry, state),
        ),
      ),
    );
  }

  Widget tvEpisodeTile(
    BuildContext context,
    TVEpisode episode,
    TVSeriesView state,
  ) {
    final enableStreaming = allowStreaming(context);
    final title = episode.title;
    final subtitle = merge([
      'Episode ${episode.episode}',
      ymd(episode.date),
      episode.vote,
    ]);
    return ListTile(
      enabled: enableStreaming,
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => _onEpisode(context, episode),
    );
  }

  void _onEpisode(BuildContext context, TVEpisode episode) {
    Navigator.push(
      context,
      CupertinoPageRoute<void>(builder: (_) => TVEpisodePage(episode)),
    );
  }
}

class _PageEntry {
  final Widget? icon;
  final String? title;
  final void Function(BuildContext, TVEpisodeView)? onSelected;

  _PageEntry({this.icon, this.title, this.onSelected});
}

class TVEpisodePage extends ClientPage<TVEpisodeView> {
  final TVEpisode episode;

  TVEpisodePage(this.episode, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvEpisode(episode.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVEpisodeView state) {
    final offset = context.offsets.state.get(state.episode);
    final entries = [
      if (offset != null)
        _PageEntry(
          icon: const Icon(Icons.play_arrow),
          title: context.strings.resumeLabel,
          onSelected: onResume,
        ),
      _PageEntry(
        icon: const Icon(Icons.play_arrow),
        title: context.strings.playLabel,
        onSelected: onPlay,
      ),
    ];
    final subtitle = merge([
      Duration(minutes: state.episode.runtime).inHoursMinutes,
      state.episode.se,
      ymd(state.episode.date),
      state.episode.vote,
    ]);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: RotaryList<_PageEntry>(
          entries,
          title: state.episode.name,
          subtitle: subtitle,
          tileBuilder: (context, entry) => _episodeTile(context, entry, state),
        ),
      ),
    );
  }

  Widget _episodeTile(
    BuildContext context,
    _PageEntry entry,
    TVEpisodeView state,
  ) {
    final enableStreaming = allowStreaming(context);
    final title = entry.title;
    return ListTile(
      enabled: enableStreaming,
      leading: entry.icon,
      title: title != null ? Text(title) : null,
      onTap: () => entry.onSelected?.call(context, state),
    );
  }

  void onPlay(BuildContext context, TVEpisodeView state) {
    playVideo(context, VideoTrack.fromTVEpisode(state));
  }

  void onResume(BuildContext context, TVEpisodeView state) {
    final offset = context.offsets.state.get(state.episode);
    final startOffset = offset != null
        ? Duration(seconds: offset.offset)
        : null;
    playVideo(context, VideoTrack.fromTVEpisode(state), startOffset: startOffset);
  }
}
