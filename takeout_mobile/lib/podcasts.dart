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
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/buttons.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/art/scaffold.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'nav.dart';
import 'style.dart';
import 'tiles.dart';

class SeriesWidget extends ClientPage<SeriesView> {
  final Series _series;

  SeriesWidget(this._series, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.series(_series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, SeriesView state) {
    return scaffold(context,
        image: _series.image,
        body: (color) => RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
                builder: (context, cacheState) {
              final isCached = cacheState.containsAll(state.episodes);
              final screen = MediaQuery.of(context).size;
              final expandedHeight = screen.height / 2;
              return CustomScrollView(slivers: [
                SliverAppBar(
                  // actions: [ ],
                  expandedHeight: expandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                      // centerTitle: true,
                      // title: Text(release.name, style: TextStyle(fontSize: 15)),
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle
                      ],
                      background: Stack(fit: StackFit.expand, children: [
                        releaseSmallCover(context, _series.image),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.75),
                              end: Alignment(0.0, 0.0),
                              colors: <Color>[
                                Color(0x60000000),
                                Color(0x00000000),
                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: _playButton(context, isCached)),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: _downloadButton(context, state, isCached)),
                      ])),
                ),
                SliverToBoxAdapter(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                        child: Column(children: [
                          _title(context),
                        ]))),
                SliverToBoxAdapter(
                    child: _SeriesEpisodeListWidget(state, color)),
              ]);
            })));
  }

  Widget _title(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Text(_series.title,
            style: Theme.of(context).textTheme.headlineSmall));
  }

  Widget _playButton(BuildContext context, bool isCached) {
    return isCached
        ? IconButton(
            icon: const Icon(Icons.play_arrow, size: 32),
            onPressed: () => _onPlay(context))
        : StreamingButton(onPressed: () => _onPlay(context));
  }

  Widget _downloadButton(BuildContext context, SeriesView view, bool isCached) {
    return isCached
        ? IconButton(icon: const Icon(iconsDownloadDone), onPressed: () => {})
        : DownloadButton(onPressed: () => _onDownload(context, view));
  }

  void _onPlay(BuildContext context) {
    context.playlist.replace(_series.reference,
        mediaType: MediaType.podcast,
        creator: _series.creator,
        title: _series.title);
  }

  void _onDownload(BuildContext context, SeriesView view) {
    context.downloadSeries(view.series);
  }
}

class _SeriesEpisodeListWidget extends StatelessWidget {
  final SeriesView _view;
  final Color? backgroundColor;

  const _SeriesEpisodeListWidget(this._view, this.backgroundColor);

  @override
  Widget build(BuildContext context) {
    final episodes = List<Episode>.from(_view.episodes.map((e) =>
        e.copyWith(album: _view.series.title, image: _view.series.image)));
    return Builder(builder: (context) {
      final downloads = context.watch<DownloadCubit>();
      final trackCache = context.watch<TrackCacheCubit>();
      final offsets = context.watch<OffsetCacheCubit>();
      return Column(children: [
        ...episodes.asMap().keys.toList().map((index) => ListTile(
            isThreeLine: true,
            trailing: _trailing(
                context, downloads.state, trackCache.state, episodes[index]),
            onTap: () => _onEpisode(context, episodes[index], index),
            onLongPress: () => _onPlay(context, episodes[index]),
            title: Text(episodes[index].title),
            subtitle: _subtitle(context, offsets.state, episodes[index])))
      ]);
    });
  }

  Widget _subtitle(
      BuildContext context, OffsetCacheState offsets, Episode episode) {
    return Builder(builder: (context) {
      final children = <Widget>[];
      final remaining = offsets.remaining(episode);
      if (remaining != null && remaining.inSeconds > 0) {
        final value = offsets.value(episode);
        if (value != null) {
          children.add(LinearProgressIndicator(value: value));
        }
      }
      children
          .add(RelativeDateWidget.from(episode.date, prefix: episode.author));
      return Column(
          children: children, crossAxisAlignment: CrossAxisAlignment.start);
    });
  }

  Widget? _trailing(BuildContext context, DownloadState downloadState,
      TrackCacheState trackCache, Episode episode) {
    if (trackCache.contains(episode)) {
      return const Icon(iconsCached);
    }
    final progress = downloadState.progress(episode);
    return (progress != null)
        ? CircularProgressIndicator(value: progress.value)
        : null;
  }

  // void _onCache(BuildContext context, bool isCached, Episode episode) {
  //   if (isCached) {
  //     Downloads.deleteEpisode(episode);
  //   } else {
  //     Downloads.downloadSeriesEpisode(_view.series, episode);
  //   }
  // }

  void _onEpisode(BuildContext context, Episode episode, int index) {
    push(context,
        builder: (_) => _EpisodeWidget(episode, _view.series.title,
            backgroundColor: backgroundColor));
  }

  void _onPlay(BuildContext context, Episode episode) {
    context.playlist.replace(episode.reference,
        mediaType: MediaType.podcast,
        creator: episode.creator,
        title: episode.title);
  }
}

class _EpisodeWidget extends StatefulWidget {
  final Episode episode;
  final String title;
  final Color? backgroundColor;

  const _EpisodeWidget(this.episode, this.title, {this.backgroundColor});

  @override
  State<_EpisodeWidget> createState() => _EpisodeWidgetState();
}

class _EpisodeWidgetState extends State<_EpisodeWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    // TODO consider changing CSS font colors based on theme
    controller.loadHtmlString("""<!DOCTYPE html>
    <html>
      <head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head>
      <body style='margin: 48;'>
        <div>
          ${widget.episode.description}
        </div>
      </body>
    </html>""");

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(16);
    return Scaffold(
        backgroundColor: widget.backgroundColor,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(builder: (context) {
          final episode = widget.episode;
          final offsetCache = context.watch<OffsetCacheCubit>().state;
          final trackCache = context.watch<TrackCacheCubit>().state;
          final when = offsetCache.when(episode);
          final duration = offsetCache.duration(episode);
          final remaining = offsetCache.remaining(episode);
          final isCached = trackCache.contains(episode);
          var title = episode.creator;
          var subtitle = merge([
            ymd(episode.date),
            if (duration != null) duration.inHoursMinutes
          ]);
          return Column(
            children: [
              Container(
                  padding: padding,
                  alignment: Alignment.centerLeft,
                  child: Text(episode.title,
                      style: Theme.of(context).textTheme.titleLarge)),
              ListTile(
                title: Text(title, overflow: TextOverflow.ellipsis),
                subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
                trailing: _downloadButton(context),
              ),
              _progress(offsetCache) ?? const EmptyWidget(),
              Expanded(child: WebViewWidget(controller: _controller)),
              ListTile(
                title: remaining != null
                    ? Text('${remaining.inHoursMinutes} remaining') // TODO intl
                    : const EmptyWidget(),
                subtitle: when != null
                    ? RelativeDateWidget(when)
                    : const EmptyWidget(),
                leading: _playButton(context, isCached),
              ),
            ],
          );
        }));
  }

  Widget? _progress(OffsetCacheState state) {
    final episode = widget.episode;
    final remaining = state.remaining(episode);
    if (remaining != null && remaining.inSeconds > 0) {
      final value = state.value(episode);
      if (value != null) {
        return LinearProgressIndicator(value: value);
      }
    }
    return null;
  }

  Widget _downloadButton(BuildContext context) {
    final episode = widget.episode;
    return Builder(builder: (context) {
      final downloads = context.watch<DownloadCubit>().state;
      final trackCache = context.watch<TrackCacheCubit>().state;
      final download = downloads.get(episode);
      final isCached = trackCache.contains(episode);
      if (isCached) {
        return const Icon(iconsDownloadDone);
      } else if (download != null) {
        final value = download.progress?.value;
        return CircularProgressIndicator(value: value);
      } else {
        return DownloadButton(onPressed: () => _onDownload(context));
      }
    });
  }

  void _onDownload(BuildContext context) {
    context.downloadEpisode(widget.episode);
  }

  Widget _playButton(BuildContext context, bool isCached) {
    return isCached
        ? PlayButton(onPressed: () => _onPlay(context))
        : StreamingButton(onPressed: () => _onPlay(context));
  }

  void _onPlay(BuildContext context) {
    context.playlist.replace(widget.episode.reference,
        mediaType: MediaType.podcast,
        creator: widget.episode.creator,
        title: widget.episode.title);
  }
}

class SeriesListWidget extends StatelessWidget {
  final List<Series> _list;

  const SeriesListWidget(this._list, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._list.asMap().keys.toList().map((index) => ListTile(
          onTap: () => _onTapped(context, _list[index]),
          leading: tileCover(context, _list[index].image),
          subtitle: Text(
              merge([
                ymd(_list[index].date),
                _list[index].author,
              ]),
              overflow: TextOverflow.ellipsis),
          title: Text(_list[index].title)))
    ]);
  }

  void _onTapped(BuildContext context, Series series) {
    push(context, builder: (_) => SeriesWidget(series));
  }
}

class EpisodeListWidget extends StatelessWidget {
  final List<Episode> _list;

  const EpisodeListWidget(this._list, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._list.asMap().keys.toList().map((index) => ListTile(
          onTap: () => _onTapped(context, _list[index]),
          leading: tilePodcast(context, _list[index].image),
          subtitle: Text(
              merge([
                ymd(_list[index].date),
                _list[index].author,
              ]),
              overflow: TextOverflow.ellipsis),
          title: Text(_list[index].title)))
    ]);
  }

  void _onTapped(BuildContext context, Episode episode) {
    push(context,
        builder: (_) => _EpisodeWidget(episode, '')); // TODO need title
  }
}
