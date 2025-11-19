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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/downloads.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/widgets/buttons.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/style.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

const radioCreator = 'Radio';
const radioStream = 'stream';

class RadioWidget extends ClientPage<RadioView> {
  RadioWidget({super.key});

  List<Spiff> _radioFilter(Iterable<Spiff> entries) {
    final list = List<Spiff>.from(entries);
    list.retainWhere((spiff) => spiff.creator == radioCreator);
    return list;
  }

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.radio(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, RadioView state) {
    return BlocBuilder<SpiffCacheCubit, SpiffCacheState>(
      builder: (context, cacheState) {
        final entries = _radioFilter(cacheState.spiffs ?? <Spiff>[]);
        bool hasDownloads = entries.isNotEmpty;

        final hasGenre = isNotEmpty(state.genre);
        final hasPeriod = isNotEmpty(state.period);
        final hasSeries = isNotEmpty(state.series);
        final hasOther = isNotEmpty(state.other);
        final hasStream = isNotEmpty(state.stream);

        final empty =
            !hasGenre && !hasPeriod && !hasSeries && !hasOther && !hasStream;

        if (empty) {
          return RefreshIndicator(
            child: Scaffold(
              appBar: AppBar(
                title: header(context.strings.radioLabel),
                actions: [
                  popupMenu(context, [
                    PopupItem.reload(context, (_) => reloadPage(context)),
                  ]),
                ],
              ),
              body: Center(
                child: TextButton(
                  child: Text(context.strings.radioEmpty),
                  onPressed: () => reloadPage(context),
                ),
              ),
            ),
            onRefresh: () => reloadPage(context),
          );
        }

        return DefaultTabController(
          length: hasDownloads ? 5 : 4, // TODO FIXME
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
                    if (hasStream) Tab(text: context.strings.streamsLabel),
                    if (hasGenre) Tab(text: context.strings.genresLabel),
                    if (hasPeriod) Tab(text: context.strings.decadesLabel),
                    if (hasSeries || hasOther)
                      Tab(text: context.strings.otherLabel),
                    if (hasDownloads) Tab(text: context.strings.downloadsLabel),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  if (hasStream) _stations(state.stream!),
                  if (hasGenre) _stations(state.genre!),
                  if (hasPeriod) _stations(state.period!),
                  if (hasSeries || hasOther)
                    _stations(
                      _merge(
                        state.series != null ? state.series! : [],
                        state.other != null ? state.other! : [],
                      ),
                    ),
                  if (hasDownloads) DownloadListWidget(filter: _radioFilter),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        final station = stations[index];
        final isStream = station.type == radioStream;
        return isStream
            ? StreamingTile(
                onTap: () => _onRadioStream(context, station),
                leading: station.image.isNotEmpty
                    ? tileCover(context, station.image)
                    : null,
                title: Text(station.name),
                subtitle: _stationSubtitle(station),
                isThreeLine: station.description.isNotEmpty,
                trailing: const Icon(Icons.play_arrow),
              )
            : ListTile(
                onTap: () => _onStation(context, station),
                leading: station.image.isNotEmpty
                    ? tileCover(context, station.image)
                    : null,
                title: Text(station.name),
                subtitle: _stationSubtitle(station),
                isThreeLine: station.description.isNotEmpty,
                trailing: DownloadButton(
                  onPressed: () => _onDownload(context, station),
                ),
              );
      },
    );
  }

  Widget? _stationSubtitle(Station station) {
    var creator = station.creator;
    if (creator == 'Radio' || creator == 'Takeout' || creator == 'TakeoutFM') {
      // auto created by server, no need to display these
      creator = '';
    }
    if (station.description.isNotEmpty && creator.isNotEmpty) {
      return Text(merge([creator, station.description]));
    } else if (creator.isNotEmpty) {
      return Text(creator);
    } else if (station.description.isNotEmpty) {
      return Text(station.description);
    }
    return null;
  }

  void _onRadioStream(BuildContext context, Station station) {
    context.stream(station.id);
  }

  void _onStation(BuildContext context, Station station) {
    pushSpiff(
      ref: '/api/stations/${station.id}/playlist',
      context,
      (client, {Duration? ttl}) =>
          client.station(station.id, ttl: Duration.zero),
    );
  }

  void _onDownload(BuildContext context, Station station) {
    context.downloadStation(station);
  }
}
