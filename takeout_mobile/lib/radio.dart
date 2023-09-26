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
import 'package:takeout_mobile/tiles.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';

import 'downloads.dart';
import 'menu.dart';
import 'nav.dart';
import 'style.dart';

const radioCreator = 'Radio';
const radioStream = 'stream';

class RadioWidget extends NavigatorClientPage<RadioView> {
  RadioWidget({super.key});

  List<Spiff> _radioFilter(Iterable<Spiff> entries) {
    final list = List<Spiff>.from(entries);
    list.retainWhere((spiff) => spiff.creator == radioCreator);
    return list;
  }

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.radio(ttl: ttl);
  }

  bool _notEmpty(final List<dynamic>? l) {
    return l != null && l.isNotEmpty;
  }

  @override
  Widget page(BuildContext context, RadioView state) {
    return BlocBuilder<SpiffCacheCubit, SpiffCacheState>(
        builder: (context, cacheState) {
      final entries = _radioFilter(cacheState.spiffs ?? <Spiff>[]);
      bool haveDownloads = entries.isNotEmpty;
      // haveDownloads = false;
      return DefaultTabController(
          length: haveDownloads ? 5 : 4, // TODO FIXME
          child: RefreshIndicator(
              onRefresh: () => reloadPage(context),
              child: Scaffold(
                  appBar: AppBar(
                      title: header(context.strings.radioLabel),
                      actions: [
                        popupMenu(context, [
                          PopupItem.reload(context, (_) => reloadPage(context)),
                        ]),
                      ],
                      bottom: TabBar(
                        tabs: [
                          if (_notEmpty(state.genre))
                            Tab(text: context.strings.genresLabel),
                          if (_notEmpty(state.period))
                            Tab(text: context.strings.decadesLabel),
                          if (_notEmpty(state.series) || _notEmpty(state.other))
                            Tab(text: context.strings.otherLabel),
                          if (_notEmpty(state.stream))
                            Tab(text: context.strings.streamsLabel),
                          if (haveDownloads)
                            Tab(text: context.strings.downloadsLabel)
                        ],
                      )),
                  body: TabBarView(
                    children: [
                      if (_notEmpty(state.genre)) _stations(state.genre!),
                      if (_notEmpty(state.period)) _stations(state.period!),
                      if (_notEmpty(state.series) || _notEmpty(state.other))
                        _stations(_merge(
                            state.series != null ? state.series! : [],
                            state.other != null ? state.other! : [])),
                      if (_notEmpty(state.stream)) _stations(state.stream!),
                      if (haveDownloads)
                        DownloadListWidget(filter: _radioFilter)
                    ],
                  ))));
    });
  }

  List<Station> _merge(List<Station> a, List<Station> b) {
    final list = a + b;
    list.sort((x, y) => x.name.compareTo(y.name));
    return list;
  }

  Widget _stations(List<Station> stations) {
    return ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final isStream = stations[index].type == radioStream;
          return isStream
              ? StreamingTile(
                  onTap: () => _onRadioStream(context, stations[index]),
                  leading: const Icon(Icons.radio),
                  title: Text(stations[index].name),
                  trailing: const Icon(Icons.play_arrow))
              : ListTile(
                  title: Text(stations[index].name),
                  onTap: () => _onStation(context, stations[index]),
                  trailing: DownloadButton(
                      onPressed: () => _onDownload(context, stations[index])));
        });
  }

  void _onRadioStream(BuildContext context, Station station) {
    context.stream(station.id);
  }

  void _onStation(BuildContext context, Station station) {
    pushSpiff(
        context,
        (client, {Duration? ttl}) =>
            client.station(station.id, ttl: Duration.zero));
  }

  void _onDownload(BuildContext context, Station station) {
    context.downloadStation(station);
  }
}
