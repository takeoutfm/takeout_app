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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/settings.dart';

import 'list.dart';

class RadioEntry {
  final String title;
  final List<Station> Function() stations;
  final Widget? icon;

  RadioEntry(this.title, this.stations, {this.icon = const Icon(Icons.radio)});
}

class RadioPage extends ClientPage<RadioView> {
  RadioPage({super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.radio(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, RadioView state) {
    final entries = [
      RadioEntry(context.strings.genresLabel, () => state.genre ?? []),
      RadioEntry(context.strings.decadesLabel, () => state.period ?? []),
      RadioEntry(context.strings.otherLabel, () => state.other ?? []),
      RadioEntry(context.strings.streamsLabel, () => state.stream ?? []),
    ];
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: RotaryList<RadioEntry>(entries,
                tileBuilder: radioTile, title: context.strings.radioLabel)));
  }

  Widget radioTile(BuildContext context, RadioEntry entry) {
    return ListTile(
        leading: entry.icon,
        title: Text(entry.title),
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute<void>(
                  builder: (_) => stationsPage(entry.title, entry.stations())));
        });
  }

  Widget stationsPage(String title, List<Station> stations) {
    return Scaffold(
      body: RotaryList<Station>(
        stations,
        tileBuilder: stationTile,
        title: title,
      ),
    );
  }

  Widget stationTile(BuildContext context, Station station) {
    final enableStreaming = allowStreaming(context);
    return ListTile(
        enabled: enableStreaming,
        title: Text(station.name),
        onTap: () => onStation(context, station));
  }

  void onStation(BuildContext context, Station station) {
    final mediaType = station.type == MediaType.stream.name
        ? MediaType.stream
        : MediaType.music;
    context.playlist.replace(station.reference,
        mediaType: mediaType,
        title: station.name,
        creator: context.strings.radioLabel);
    context.showPlayer(context);
  }
}
