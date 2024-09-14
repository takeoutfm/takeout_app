// Copyright 2023 defsub
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/spiff/widget.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/spiff/model.dart';

import 'menu.dart';
import 'nav.dart';
import 'tiles.dart';

class DownloadsWidget extends StatelessWidget {
  const DownloadsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(context.strings.downloadsLabel), actions: [
          popupMenu(context, [
            PopupItem.delete(
                context, context.strings.deleteAll, (ctx) => _onDeleteAll(ctx)),
          ])
        ]),
        body: const SingleChildScrollView(
            child: Column(
          children: [
            DownloadListWidget(),
          ],
        )));
  }

  void _onDeleteAll(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(context.strings.confirmDelete),
            content: Text(context.strings.deleteDownloadedTracks),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () {
                  _onDeleteConfirmed(context);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
        });
  }

  void _onDeleteConfirmed(BuildContext context) {
    context.removeDownloads();
  }
}

class DownloadListWidget extends StatefulWidget {
  final int limit;
  final DownloadSortType sortType;
  final List<Spiff> Function(List<Spiff>)? filter;

  const DownloadListWidget(
      {super.key,
      this.sortType = DownloadSortType.name,
      this.limit = -1,
      this.filter});

  @override
  DownloadListState createState() => DownloadListState();
}

enum DownloadSortType { oldest, newest, name, size }

final epoch = DateTime.fromMillisecondsSinceEpoch(0);

int _compare(DateTime? a, DateTime? b) => (a ?? epoch).compareTo(b ?? epoch);

void downloadsSort(DownloadSortType sortType, List<Spiff> entries) {
  switch (sortType) {
    case DownloadSortType.oldest:
      entries.sort((a, b) => _compare(a.lastModified, b.lastModified));
    case DownloadSortType.newest:
      entries.sort((a, b) => _compare(b.lastModified, a.lastModified));
    case DownloadSortType.name:
      entries.sort((a, b) => a.title.compareTo(b.title));
    case DownloadSortType.size:
      entries.sort((a, b) => a.size.compareTo(b.size));
  }
}

class DownloadListState extends State<DownloadListWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpiffCacheCubit, SpiffCacheState>(
        builder: (context, state) {
      var entries = List<Spiff>.from(state.spiffs ?? <Spiff>[]);
      if (widget.filter != null) {
        entries = widget.filter!(entries);
      }
      downloadsSort(widget.sortType, entries);
      return Column(children: [
        ...entries
            .sublist(
                0,
                widget.limit == -1
                    ? entries.length
                    : min(widget.limit, entries.length))
            .map((entry) => AlbumListTile(
                context, entry.creator, entry.title, entry.cover,
                trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _onPlay(context, entry)),
                onTap: () => _onTap(context, entry)))
      ]);
    });
  }

  void _onTap(BuildContext context, Spiff spiff) {
    push(context, builder: (_) => SpiffWidget(value: spiff));
  }

  void _onPlay(BuildContext context, Spiff spiff) {
    if (spiff.isMusic() || spiff.isPodcast()) {
      context.play(spiff);
    } else if (spiff.isVideo()) {
      final entry = spiff.playlist.tracks.first;
      context.showMovie(entry);
    }
  }
}
