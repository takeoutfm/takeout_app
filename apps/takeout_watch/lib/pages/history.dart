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
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/model.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/widgets/list.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(builder: (context, state) {
      final spiffs = List<SpiffHistory>.from(state.history.spiffs);
      spiffs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return Scaffold(
          body: RotaryList<SpiffHistory>(spiffs,
              tileBuilder: spiffTile, title: context.strings.recentLabel));
    });
  }

  Widget spiffTile(BuildContext context, SpiffHistory entry) {
    return ListTile(
        title: Text(entry.spiff.playlist.title),
        subtitle: Text(entry.spiff.playlist.creator ?? ''),
        onTap: () => onPlay(context, entry.spiff));
  }

  void onPlay(BuildContext context, Spiff spiff) {
    context.play(spiff);
    context.showPlayer(context);
  }
}
