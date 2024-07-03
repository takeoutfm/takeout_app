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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/settings.dart';

import 'list.dart';

class PlaylistsPage extends ClientPage<PlaylistsView> {
  PlaylistsPage({super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.playlists(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, PlaylistsView state) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: RotaryList<PlaylistView>(state.playlists,
                tileBuilder: playlistTile,
                title: context.strings.playlistsLabel)));
  }

  Widget playlistTile(BuildContext context, PlaylistView entry) {
    final enableStreaming = allowStreaming(context);
    return ListTile(
        enabled: enableStreaming,
        leading: const Icon(Icons.playlist_play),
        title: Text(entry.name),
        onTap: () => onPlay(context, entry));
  }

  void onPlay(BuildContext context, PlaylistView playlist) {
    context.playlist.replace(
      '/music/playlists/${playlist.id}',
      creator: '',
      mediaType: MediaType.music,
      title: playlist.name,
    );
    context.showPlayer(context);
  }
}
