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
import 'package:takeout_mobile/app/context.dart';

import 'style.dart';

typedef MenuCallback = void Function(BuildContext);

class PopupItem {
  final Icon? icon;
  final String? title;
  final MenuCallback? onSelected;
  final bool divider;

  bool get isDivider => divider;

  factory PopupItem.divider() => const PopupItem(null, '', null, divider: true);

  const PopupItem(this.icon, this.title, this.onSelected,
      {this.divider = false});

  PopupItem.music(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.music_note), context.strings.musicSwitchLabel,
            onSelected);

  PopupItem.video(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.movie), context.strings.videoSwitchLabel,
            onSelected);

  PopupItem.podcasts(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.podcasts), context.strings.podcastsSwitchLabel,
            onSelected);

  PopupItem.downloads(BuildContext context, MenuCallback onSelected)
      : this(const Icon(iconsDownload), context.strings.downloadsLabel,
            onSelected);

  PopupItem.download(BuildContext context, MenuCallback onSelected)
      : this(const Icon(iconsDownload), context.strings.downloadsLabel,
            onSelected);

  PopupItem.play(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.play_arrow), context.strings.playLabel,
            onSelected);

  PopupItem.reload(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.refresh_sharp), context.strings.refreshLabel,
            onSelected);

  PopupItem.logout(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.logout), context.strings.logoutLabel, onSelected);

  PopupItem.link(BuildContext context, String text, MenuCallback onSelected)
      : this(const Icon(Icons.link), text, onSelected);

  PopupItem.about(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.info_outline), context.strings.aboutLabel,
            onSelected);

  PopupItem.settings(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.settings), context.strings.settingsLabel,
            onSelected);

  PopupItem.delete(BuildContext context, String text, MenuCallback onSelected)
      : this(const Icon(Icons.delete), text, onSelected);

  PopupItem.singles(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.audiotrack_outlined),
            context.strings.singlesLabel, onSelected);

  PopupItem.popular(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.audiotrack_outlined),
            context.strings.popularLabel, onSelected);

  PopupItem.genre(BuildContext context, String genre, MenuCallback onSelected)
      : this(const Icon(Icons.people), genre, onSelected);

  PopupItem.area(BuildContext context, String area, MenuCallback onSelected)
      : this(const Icon(Icons.location_pin), area, onSelected);

  PopupItem.artist(BuildContext context, String name, MenuCallback onSelected)
      : this(const Icon(Icons.people), name, onSelected);

  PopupItem.shuffle(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.shuffle_sharp), context.strings.shuffleLabel,
            onSelected);

  PopupItem.radio(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.radio), context.strings.radioLabel, onSelected);

  PopupItem.playlist(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.playlist_play_sharp),
            context.strings.recentlyPlayed, onSelected);

  PopupItem.wantList(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.shopping_bag_outlined), context.strings.wantList,
            onSelected);

  PopupItem.syncPlaylist(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.sync), context.strings.syncPlaylist, onSelected);

  PopupItem.subscribe(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.add), context.strings.subscribe, onSelected);

  PopupItem.unsubscribe(BuildContext context, MenuCallback onSelected)
      : this(const Icon(Icons.remove), context.strings.unsubscribe, onSelected);
}

Widget popupMenu(BuildContext context, List<PopupItem> items) {
  return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) {
        List<PopupMenuEntry<int>> entries = [];
        for (var index = 0; index < items.length; index++) {
          if (items[index].isDivider) {
            entries.add(const PopupMenuDivider());
          } else {
            entries.add(PopupMenuItem<int>(
                value: index,
                child: ListTile(
                    leading: items[index].icon,
                    title: Text(items[index].title ?? 'no title'),
                    minLeadingWidth: 10)));
          }
        }
        return entries;
      },
      onSelected: (index) {
        items[index].onSelected!(context);
      });
}

void showPopupMenu(
    BuildContext context, RelativeRect position, List<PopupItem> items) async {
  List<PopupMenuEntry<int>> entries = [];
  for (var index = 0; index < items.length; index++) {
    if (items[index].isDivider) {
      entries.add(const PopupMenuDivider());
    } else {
      entries.add(PopupMenuItem<int>(
          value: index,
          child: ListTile(
              leading: items[index].icon,
              title: Text(items[index].title ?? 'no title'),
              minLeadingWidth: 10)));
    }
  }
  final selected = await showMenu(context: context, position: position, items: entries);
  if (selected != null) {
    if (!context.mounted) {
      return;
    }
    items[selected].onSelected?.call(context);
  }
}
