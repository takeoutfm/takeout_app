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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/music.dart';
import 'package:takeout_watch/podcasts.dart';
import 'package:takeout_watch/radio.dart';
import 'package:takeout_watch/settings.dart';
import 'package:takeout_watch/video.dart';

import 'downloads.dart';
import 'history.dart';
import 'list.dart';
import 'player.dart';

class HomeEntry {
  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final void Function(BuildContext, HomeView)? onSelected;

  HomeEntry(this.title, {this.icon, this.subtitle, this.onSelected});
}

class HomePage extends ClientPage<HomeView> {
  HomePage({super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.home(ttl: ttl);
  }

  @override
  void reload(BuildContext context) {
    super.reload(context);
    context.reload();
  }

  @override
  Widget page(BuildContext context, HomeView state) {
    return Builder(builder: (context) {
      final index = context.watch<IndexCubit>().state;
      final trackCache = context.watch<TrackCacheCubit>().state;
      final history = context.watch<HistoryCubit>().state.history;
      final entries = [
        // TODO hide if not playing?
        HomeEntry(
            PlayerTitle(style: Theme.of(context).listTileTheme.titleTextStyle),
            icon: const SizedBox.square(dimension: 36, child: PlayerImage()),
            subtitle: PlayerArtist(
                style: Theme.of(context).listTileTheme.subtitleTextStyle),
            onSelected: (context, state) => onPlayer(context, state)),
        if (history.spiffs.isNotEmpty)
          HomeEntry(Text(context.strings.recentLabel),
              icon: const Icon(Icons.history),
              onSelected: (context, state) => onHistory(context, state)),
        if (index.music)
          HomeEntry(Text(context.strings.musicLabel),
              icon: const Icon(Icons.music_note),
              onSelected: (context, state) => onMusic(context, state)),
        if (index.podcasts)
          HomeEntry(Text(context.strings.podcastsLabel),
              icon: const Icon(Icons.podcasts),
              onSelected: (context, state) => onPodcasts(context, state)),
        if (index.music)
          HomeEntry(Text(context.strings.radioLabel),
              icon: const Icon(Icons.radio),
              onSelected: (context, state) => onRadio(context, state)),
        if (index.music)
          HomeEntry(Text(context.strings.artistsLabel),
              icon: const Icon(Icons.people),
              onSelected: (context, state) => onArtists(context, state)),
        if (index.movies)
          HomeEntry(Text(context.strings.moviesLabel),
              icon: const Icon(Icons.movie),
              onSelected: (context, state) => onMovies(context, state)),
        if (trackCache.isNotEmpty)
          HomeEntry(Text(context.strings.downloadsLabel),
              icon: const Icon(Icons.cloud_download_outlined),
              onSelected: (context, state) => onDownloads(context, state)),
        HomeEntry(Text(context.strings.settingsLabel),
            icon: const Icon(Icons.settings),
            onSelected: (context, state) => onSettings(context, state)),
      ];
      return Scaffold(
          body: RefreshIndicator(
              onRefresh: () => reloadPage(context),
              child: RotaryList<HomeEntry>(entries,
                  title: context.strings.takeoutTitle,
                  tileBuilder: (context, entry) =>
                      homeTile(context, entry, state))));
    });
  }

  Widget homeTile(BuildContext context, HomeEntry entry, HomeView state) {
    return ListTile(
        leading: entry.icon,
        title: entry.title,
        subtitle: entry.subtitle,
        onTap: () => entry.onSelected?.call(context, state));
  }

  Widget playerButton() {
    return BlocBuilder<Player, PlayerState>(
        buildWhen: (_, state) => state is PlayerProcessingState,
        builder: (context, state) {
          if (state is PlayerProcessingState) {
            if (state.buffering) {
              return const SizedBox.square(
                  dimension: 24, child: CircularProgressIndicator());
            } else if (state.playing) {
              return IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.pause),
                  onPressed: () => context.player.pause());
            } else {
              return IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => context.player.play());
            }
          }
          return const EmptyWidget();
        });
  }

  void onMusic(BuildContext context, HomeView state) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => MusicPage(state)));
  }

  void onPodcasts(BuildContext context, HomeView state) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => PodcastsPage(state)));
  }

  void onArtists(BuildContext context, HomeView _) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => ArtistsPage()));
  }

  void onRadio(BuildContext context, HomeView _) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => RadioPage()));
  }

  void onHistory(BuildContext context, HomeView _) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => const HistoryPage()));
  }

  void onMovies(BuildContext context, HomeView state) {
    Navigator.push(context,
        CupertinoPageRoute<void>(builder: (_) => VideoPage(state)));
  }

  void onDownloads(BuildContext context, HomeView _) {
    Navigator.push(context,
        CupertinoPageRoute<void>(builder: (_) => const DownloadsPage()));
  }

  void onSettings(BuildContext context, HomeView _) {
    Navigator.push(context,
        CupertinoPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  void onPlayer(BuildContext context, HomeView _) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => const PlayerPage()));
  }
}
