// Copyright 2024 defsub
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
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/page/page.dart';

import 'dialog.dart';
import 'menu.dart';
import 'nav.dart';
import 'style.dart';

void showPlaylistAppend(BuildContext context, String ref) {
  final client = context.client;
  showPlaylistsBottomSheet(context).then((playlist) {
    if (playlist != null) {
      client.playlistAppend(playlist, ref);
    }
  });
}

void showPlaylistSelect(
    BuildContext context, void Function(PlaylistView playlist) onSelected) {
  showPlaylistsBottomSheet(context).then((playlist) {
    if (playlist != null) {
      onSelected(playlist);
    }
  });
}

Future<PlaylistView?> showPlaylistsBottomSheet(BuildContext context) {
  return showModalBottomSheet<PlaylistView>(
      context: context,
      builder: (ctx) {
        return _SelectPlaylistWidget(onSelected: (playlist) {
          Navigator.pop(ctx, playlist);
        });
      });
}

class _SelectPlaylistWidget extends ClientPage<PlaylistsView> {
  final void Function(PlaylistView) onSelected;

  _SelectPlaylistWidget({required this.onSelected});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.playlists(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, PlaylistsView state) {
    return Column(children: [
      ListTile(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(context.strings.playlists)),
      Expanded(
          child: ListView.builder(
              itemCount: state.playlists.length,
              itemBuilder: (buildContext, index) {
                final playlist = state.playlists[index];
                return ListTile(
                  leading: const Icon(Icons.playlist_add),
                  onTap: () => onSelected(playlist),
                  title: Text(playlist.name),
                  subtitle:
                      Text(context.strings.trackCount(playlist.trackCount)),
                );
              }))
    ]);
  }
}

class PlaylistsWidget extends ClientPage<PlaylistsView> {
  PlaylistsWidget({super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.playlists(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, PlaylistsView state) {
    return Scaffold(
        appBar: AppBar(title: header(context.strings.playlists), actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _onCreatePlaylist(context)),
          popupMenu(context, [
            PopupItem.reload(context, (_) => reloadPage(context)),
          ])
        ]),
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: _playlists(context, state)));
  }

  Widget _playlists(BuildContext context, PlaylistsView state) {
    return Column(children: [
      Expanded(
          child: ListView.builder(
              itemCount: state.playlists.length,
              itemBuilder: (buildContext, index) {
                final playlist = state.playlists[index];
                return ListTile(
                  leading: const Icon(Icons.playlist_play),
                  onTap: () => _onPlaylist(context, playlist),
                  title: Text(playlist.name),
                  subtitle:
                      Text(context.strings.trackCount(playlist.trackCount)),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _onDeletePlaylist(context, playlist)),
                );
              }))
    ]);
  }

  void _onCreatePlaylist(BuildContext context) {
    final client = context.client;
    textDialog(context, context.strings.playlistName).then((name) {
      if (name != null) {
        client.createPlaylist(Spiff.empty(title: name));
      }
    });
  }

  void _onDeletePlaylist(BuildContext context, PlaylistView playlist) {
    confirmDeleteDialog(context, context.strings.deletePlaylist,
        () => _onDeletePlaylistConfirmed(context, playlist));
  }

  void _onDeletePlaylistConfirmed(BuildContext context, PlaylistView playlist) {
    context.client.deletePlaylist(playlist);
  }

  void _onPlaylist(BuildContext context, PlaylistView playlist) {
    pushPlaylist(
        context,
        (client, {Duration? ttl}) =>
            client.playlist(id: playlist.id, ttl: Duration.zero));
  }
}
