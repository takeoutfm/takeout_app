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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/menu.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/spiff/widget.dart';
import 'package:takeout_mobile/style.dart';
import 'package:takeout_mobile/tiles.dart';

class HistoryListWidget extends StatelessWidget {
  const HistoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final history = historyCubit.state.history;
    final spiffs = List<SpiffHistory>.from(history.spiffs);
    spiffs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return Scaffold(
        appBar: AppBar(
          title: header(context.strings.historyLabel),
          actions: [
            popupMenu(context, [
              PopupItem.streamHistory(context, (ctx) => _onStreamHistory(ctx)),
              PopupItem.delete(
                  context, context.strings.deleteAll, (ctx) => _onDelete(ctx)),
            ])
          ],
        ),
        body: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: spiffs.length,
                  itemBuilder: (buildContext, index) {
                    return SpiffHistoryTile(spiffs[index]);
                  }))
        ]));
  }

  void _onDelete(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(context.strings.confirmDelete),
            content: Text(context.strings.deleteHistory),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _onDeleteConfirmed(ctx);
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          );
        });
  }

  Future<void> _onDeleteConfirmed(BuildContext context) async {
    context.history.remove();
  }

  void _onStreamHistory(BuildContext context) {
    push(context, builder: (_) => StreamTrackHistoryWidget());
  }
}

Widget _streamTrackList(BuildContext context) {
  return Builder(builder: (context) {
    final history = context.watch<HistoryCubit>();
    final tracks = List<StreamHistory>.from(history.state.history.stream);
    tracks.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final sameArtwork = tracks.every((t) => t.image == tracks.first.image);

    return Column(children: [
      Expanded(
          child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (buildContext, index) {
                return CoverTrackListTile.streamTrack(
                  context,
                  tracks[index],
                  showCover: !sameArtwork,
                  dateTime: tracks[index].dateTime,
                );
              })),
    ]);
  });
}

class StreamTrackHistoryWidget extends StatelessWidget {
  const StreamTrackHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: header(context.strings.streamHistory),
        ),
        body: _streamTrackList(context));
  }
}

class SpiffHistoryTile extends StatelessWidget {
  final SpiffHistory spiffHistory;
  final String _cover;

  SpiffHistoryTile(this.spiffHistory, {super.key})
      : _cover = spiffHistory.spiff.cover;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(spiffHistory.spiff.playlist.creator ?? 'no creator',
          overflow: TextOverflow.ellipsis),
      RelativeDateWidget(spiffHistory.dateTime)
    ]);

    return ListTile(
        selected: false,
        isThreeLine: true,
        onTap: () => _onTap(context, spiffHistory),
        onLongPress: null,
        leading: tileCover(context, _cover),
        trailing: null,
        subtitle: subtitle,
        title: Text(spiffHistory.spiff.playlist.title,
            overflow: TextOverflow.ellipsis));
  }

  void _onTap(BuildContext context, SpiffHistory spiffHistory) {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            // TODO consider making spiff refreshable. Need original reference or uri.
            builder: (_) => SpiffWidget(value: spiffHistory.spiff)));
  }
}
