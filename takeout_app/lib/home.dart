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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:takeout_app/app/app.dart';
import 'package:takeout_app/app/context.dart';
import 'package:takeout_app/downloads.dart';
import 'package:takeout_app/settings/widget.dart';
import 'package:takeout_app/spiff/widget.dart';
import 'package:takeout_app/tiles.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/client.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/settings/model.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'menu.dart';
import 'nav.dart';
import 'podcasts.dart';
import 'release.dart';
import 'style.dart';
import 'video.dart';

class HomeWidget extends NavigatorClientPage<HomeView> {
  static final log = Logger('HomeState');
  final VoidContextCallback _onSearch;

  HomeWidget(this._onSearch, {super.key});

  _HomeGrid _grid(HomeView view, MediaType mediaType, HomeGridType gridType,
      TrackCacheState cacheState) {
    switch (mediaType) {
      case MediaType.video:
        return _MovieHomeGrid(view, gridType, cacheState, _onSearch);
      case MediaType.music:
      case MediaType.stream: // unused for now
        return _MusicHomeGrid(view, gridType, cacheState, _onSearch);
      case MediaType.podcast:
        return _SeriesHomeGrid(view, gridType, cacheState, _onSearch);
    }
  }

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
      final mediaType = context.watch<MediaTypeCubit>();
      final trackCache = context.watch<TrackCacheCubit>();
      final settings = context.watch<SettingsCubit>();
      return Scaffold(
          body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: _grid(state, mediaType.state.mediaType,
            settings.state.settings.homeGridType, trackCache.state),
      ));
    });
  }
}

abstract class _HomeItem {
  Widget Function() get onTap;

  bool get overlay;

  Widget? get title;

  Widget? get subtitle;

  String get key;

  Widget getTrailing(BuildContext context);

  Widget image(BuildContext context);

  @override
  int get hashCode {
    return key.hashCode;
  }

  @override
  bool operator ==(Object o) {
    return o is _HomeItem && o.key == key;
  }
}

class _MediaHomeItem extends _HomeItem {
  final MediaAlbum album;
  final TrackCacheState trackCache;
  String? _key;

  _MediaHomeItem(
    this.trackCache,
    this.album,
  );

  @override
  Widget Function() get onTap {
    return () {
      if (album is _SpiffAlbum) {
        return SpiffWidget(value: (album as _SpiffAlbum).spiff);
      }
      return const EmptyWidget();
    };
  }

  @override
  bool get overlay => album.album.isNotEmpty || album.creator.isNotEmpty;

  @override
  Widget? get title => Text(album.album);

  @override
  Widget? get subtitle => album.creator.isNotEmpty ? Text(album.creator) : null;

  Widget _downloadIcon(BuildContext context, Spiff download,
      IconData completeIcon, IconData downloadingIcon) {
    final isCached = trackCache.containsAll(download.playlist.tracks);
    return Icon(isCached ? completeIcon : downloadingIcon);
  }

  @override
  Widget getTrailing(BuildContext context) {
    var year = album.year;
    if (album is _SpiffAlbum) {
      return _downloadIcon(context, (album as _SpiffAlbum).spiff,
          iconsDownloadDone, iconsDownload);
    } else if (year > 1) {
      return Text('$year');
    }
    return const EmptyWidget();
  }

  @override
  String get key {
    if (_key == null) {
      if (album.creator == 'Radio') {
        _key = '${album.album}/${album.creator}/${album.date}';
      } else {
        _key = '${album.album}/${album.creator}';
      }
    }
    return _key!;
  }

  @override
  Widget image(BuildContext context) {
    return gridCover(context, album.image);
  }
}

class _ReleaseHomeItem extends _MediaHomeItem {
  _ReleaseHomeItem(super.trackCache, super.release);

  @override
  Widget Function() get onTap {
    return () => ReleaseWidget(album as Release);
  }
}

class _MovieHomeItem extends _MediaHomeItem {
  _MovieHomeItem(super.trackCache, super.movie);

  @override
  Widget Function() get onTap {
    return () => MovieWidget(album as Movie);
  }

  @override
  String get key => (album as Movie).titleYear;

  @override
  Widget? get title => null; //(album as Movie).rating;

  @override
  Widget? get subtitle => null;

  @override
  Widget getTrailing(BuildContext context) => const EmptyWidget();

  @override
  Widget image(BuildContext context) {
    return gridPoster(context, album.image);
  }
}

class _SeriesHomeItem extends _MediaHomeItem {
  _SeriesHomeItem(super.trackCache, super.series);

  @override
  Widget Function() get onTap {
    return () => SeriesWidget(album as Series);
  }

  @override
  String get key => album.album + '/' + album.creator; // == title/author

  @override
  Widget? get title => null;

  @override
  Widget? get subtitle => RelativeDateWidget.from((album as Series).date);

  @override
  Widget getTrailing(BuildContext context) =>
      const EmptyWidget(); // no trailer (year)

  @override
  Widget image(BuildContext context) {
    return gridPoster(context, album.image);
  }
}

class _SpiffAlbum implements MediaAlbum {
  final Spiff spiff;

  _SpiffAlbum(this.spiff);

  @override
  String get creator => spiff.playlist.creator ?? '';

  @override
  String get album => spiff.playlist.title;

  @override
  String get image => spiff.cover;

  @override
  String get date => spiff.date ?? '';

  @override
  int get year {
    return -1;
  }
}

abstract class _HomeGrid extends StatelessWidget {
  final HomeView _view;
  final HomeGridType _type;
  final TrackCacheState _cacheState;
  final VoidContextCallback _onSearch;
  final _buttons =
      SplayTreeMap<MediaType, IconButton>((a, b) => a.index.compareTo(b.index));

  _HomeGrid(this._view, this._type, this._cacheState, this._onSearch);

  Iterable<_HomeItem> _items(List<Spiff> downloads);

  double _gridAspectRatio();

  double _gridMaxCrossAxisExtent();

  void _onTap(BuildContext context, _HomeItem item) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => item.onTap()));
  }

  List<_MediaHomeItem> _downloadedItems(
      MediaType mediaType, List<Spiff> downloads) {
    List<_MediaHomeItem> items = [];
    for (var d in downloads) {
      if (d.mediaType == mediaType) {
        items.add(_MediaHomeItem(_cacheState, _SpiffAlbum(d)));
      }
    }
    return items;
  }

  SliverGrid _itemGrid(BuildContext context, Iterable<_HomeItem> items) {
    int dir = 0;
    return SliverGrid.extent(
        childAspectRatio: _gridAspectRatio(),
        maxCrossAxisExtent: _gridMaxCrossAxisExtent(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          ...items.map((i) => GestureDetector(
              onTap: () => _onTap(context, i),
              onPanUpdate: (d) {
                dir = d.delta.dx < 0 ? -1 : 1;
              },
              onPanEnd: (_) {
                if (dir == -1) {
                  nextGridType(context);
                } else if (dir == 1) {
                  prevGridType(context);
                }
              },
              child: GridTile(
                footer: i.overlay
                    ? Material(
                        color: Colors.transparent,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.vertical(
                        //         bottom: Radius.circular(4))),
                        clipBehavior: Clip.antiAlias,
                        child: GridTileBar(
                          backgroundColor: Colors.black26,
                          title: i.title,
                          subtitle: i.subtitle,
                          trailing: i.getTrailing(context),
                        ))
                    : null,
                child: i.image(context),
              )))
        ]);
  }

  void nextGridType(BuildContext context) => context.selectedMediaType.next();

  void prevGridType(BuildContext context) =>
      context.selectedMediaType.previous();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndexCubit, IndexState>(builder: (context, state) {
      final mediaType = context.selectedMediaType.state.mediaType;
      const iconSize = 22.0;
      final selectedColor = Theme.of(context).indicatorColor;
      _buttons.clear();
      if (state.music) {
        _buttons[MediaType.music] = IconButton(
            iconSize: iconSize,
            color: mediaType == MediaType.music ? selectedColor : null,
            icon: const Icon(Icons.audiotrack),
            onPressed: () => _onMusicSelected(context));
      }
      if (state.movies) {
        _buttons[MediaType.video] = IconButton(
            iconSize: iconSize,
            color: mediaType == MediaType.video ? selectedColor : null,
            icon: const Icon(Icons.movie),
            onPressed: () => _onVideoSelected(context));
      }
      if (state.podcasts) {
        _buttons[MediaType.podcast] = IconButton(
            iconSize: iconSize,
            color: mediaType == MediaType.podcast ? selectedColor : null,
            icon: const Icon(Icons.podcasts),
            onPressed: () => _onPodcastsSelected(context));
      }

      final iconBar = <Widget>[];
      // below adds circular progress indicator status bar
      // if (_cacheSnapshot.downloading.isNotEmpty) {
      //   // add icon to show download progress
      //   final downloadProgress = _cacheSnapshot.downloading.values
      //       .fold<DownloadSnapshot>(
      //           DownloadSnapshot(0, 0),
      //           (total, e) => DownloadSnapshot(
      //               total.size + e.size, total.offset + e.offset));
      //   iconBar.add(Center(
      //       child: SizedBox(
      //           width: iconSize,
      //           height: iconSize,
      //           child:
      //               CircularProgressIndicator(value: downloadProgress.value))));
      // }
      iconBar.addAll(_buttons.values);

      return CustomScrollView(slivers: [
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,
          leading: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _onSearch(context)),
          // title: header(context.strings.takeoutTitle),
          actions: [
            ...iconBar,
            popupMenu(context, [
              PopupItem.playlist(
                  context, (context) => _onRecentTracks(context)),
              PopupItem.popular(
                  context, (context) => _onPopularTracks(context)),
              PopupItem.divider(),
              PopupItem.settings(context, (context) => _onSettings(context)),
              PopupItem.downloads(context, (context) => _onDownloads(context)),
              PopupItem.logout(context, (_) => _onLogout(context)),
              PopupItem.divider(),
              PopupItem.about(context, (context) => _onAbout(context)),
            ]),
          ],
          bottom: _appBarBottom(),
        ),
        BlocBuilder<SpiffCacheCubit, SpiffCacheState>(
            builder: (context, cacheState) {
          final downloads = List<Spiff>.from(cacheState.spiffs ?? <Spiff>[]);
          downloadsSort(DownloadSortType.newest, downloads);
          return _itemGrid(context, _items(downloads));
        })
      ]);
    });
  }

  // void _onSearch(BuildContext context) {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => SearchWidget()));
  // }

  PreferredSizeWidget? _appBarBottom() {
    return null;
    // return _cacheState.downloading.isNotEmpty
    //     ? PreferredSize(
    //         child: LinearProgressIndicator(value: _cacheSnapshot.fold().value),
    //         preferredSize: Size.fromHeight(4.0),
    //       )
    //     : null;
  }

  void _onVideoSelected(BuildContext context) {
    context.selectedMediaType.select(MediaType.video);
  }

  void _onMusicSelected(BuildContext context) {
    context.selectedMediaType.select(MediaType.music);
  }

  void _onPodcastsSelected(BuildContext context) {
    context.selectedMediaType.select(MediaType.podcast);
  }

  void _onDownloads(BuildContext context) {
    push(context, builder: (_) => const DownloadsWidget());
  }

  void _onSettings(BuildContext context) {
    push(context, builder: (_) => const SettingsWidget());
  }

  void _onRecentTracks(BuildContext context) {
    pushSpiff(
        context,
        (ClientCubit client, {Duration? ttl}) =>
            client.recentTracks(ttl: Duration.zero));
  }

  void _onPopularTracks(BuildContext context) {
    pushSpiff(
        context,
        (ClientCubit client, {Duration? ttl}) =>
            client.popularTracks(ttl: Duration.zero));
  }

  void _onLogout(BuildContext context) {
    context.logout();
  }

  void _onAbout(BuildContext context) {
    showAboutDialog(
        context: context,
        applicationName: context.strings.takeoutTitle,
        applicationVersion: appVersion,
        applicationLegalese: 'Copyleft \u00a9 2020-2023 defsub',
        children: <Widget>[
          InkWell(
              child: const Text(
                appSource,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueAccent),
              ),
              onTap: () => launchUrl(Uri.parse(appSource))),
          InkWell(
              child: const Text(
                appHome,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueAccent),
              ),
              onTap: () => launchUrl(Uri.parse(appHome))),
        ]);
  }
}

class _MusicHomeGrid extends _HomeGrid {
  _MusicHomeGrid(super.view, super._type, super._cacheState, super._onSearch);

  @override
  double _gridAspectRatio() => coverAspectRatio;

  @override
  double _gridMaxCrossAxisExtent() => coverGridWidth;

  @override
  Iterable<_HomeItem> _items(List<Spiff> downloads) {
    switch (_type) {
      case HomeGridType.released:
        return _view.released.map((r) => _ReleaseHomeItem(_cacheState, r));
      case HomeGridType.added:
        return _view.added.map((r) => _ReleaseHomeItem(_cacheState, r));
      case HomeGridType.downloads:
        return _downloadedItems(MediaType.music, downloads);
      case HomeGridType.mix:
        final LinkedHashSet<_HomeItem> items = LinkedHashSet();
        items.addAll(_downloadedItems(MediaType.music, downloads));
        for (var r in _view.added) {
          items.add(_ReleaseHomeItem(_cacheState, r));
        }
        return items;
    }
  }
}

class _MovieHomeGrid extends _HomeGrid {
  _MovieHomeGrid(super.view, super._type, super._cacheState, super._onSearch);

  @override
  double _gridAspectRatio() => posterAspectRatio;

  @override
  double _gridMaxCrossAxisExtent() => posterGridWidth;

  @override
  Iterable<_HomeItem> _items(List<Spiff> downloads) {
    switch (_type) {
      case HomeGridType.released:
        return _view.newMovies.map((v) => _MovieHomeItem(_cacheState, v));
      case HomeGridType.added:
        return _view.addedMovies.map((v) => _MovieHomeItem(_cacheState, v));
      case HomeGridType.downloads:
        return _downloadedItems(MediaType.video, downloads);
      case HomeGridType.mix:
        final LinkedHashSet<_HomeItem> items = LinkedHashSet();
        items.addAll(_downloadedItems(MediaType.video, downloads));
        for (var v in _view.addedMovies) {
          items.add(_MovieHomeItem(_cacheState, v));
        }
        return items;
    }
  }
}

class _SeriesHomeGrid extends _HomeGrid {
  _SeriesHomeGrid(super.view, super._type, super._cacheState, super._onSearch);

  @override
  double _gridAspectRatio() => seriesAspectRatio;

  @override
  double _gridMaxCrossAxisExtent() => seriesGridWidth;

  @override
  Iterable<_HomeItem> _items(List<Spiff> downloads) {
    switch (_type) {
      case HomeGridType.released:
      case HomeGridType.added:
        return _view.newSeries!.map((v) => _SeriesHomeItem(_cacheState, v));
      case HomeGridType.downloads:
        final items = <_HomeItem>[];
        final downloadedItems = _downloadedItems(MediaType.podcast, downloads);
        for (var v in _view.newSeries!) {
          // use series items with downloads over download items
          final seriesItem = _SeriesHomeItem(_cacheState, v);
          if (downloadedItems.any((e) => e.key == seriesItem.key)) {
            items.add(seriesItem);
          }
        }
        return items;
      case HomeGridType.mix:
        // final LinkedHashSet<_HomeItem> items = LinkedHashSet();
        // items.addAll(_downloadedItems(MediaType.podcast, downloads));
        // _view.newSeries!
        //     .forEach((v) => items.add(_SeriesHomeItem(_cacheSnapshot, v)));
        // prefer series items over downloads
        final items =
            _view.newSeries!.map((v) => _SeriesHomeItem(_cacheState, v));
        return items;
    }
  }
}
