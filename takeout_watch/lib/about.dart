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

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_watch/app/app.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/platform.dart';

import 'list.dart';

class AboutEntry {
  final String title;
  final String? subtitle;
  final void Function()? onTap;

  AboutEntry(this.title, {this.subtitle, this.onTap});
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ConnectivityCubit>();
    context.watch<TrackCacheCubit>();
    return Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
            future: deviceInfo(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              //data.forEach((key, value) { print('$key => $value'); });
              final entries = [
                AboutEntry('Copyleft \u00a9 2023-2024',
                    subtitle: 'defsub'),
                AboutEntry(context.strings.connectivityLabel,
                    subtitle: context.connectivity.state.type.name,
                    onTap: () => context.connectivity.check()),
                AboutEntry(
                  context.strings.downloadsLabel,
                  subtitle: downloadsSize(context),
                ),
                AboutEntry('Dart', subtitle: Platform.version),
                if (data.isNotEmpty)
                  AboutEntry(context.strings.deviceLabel,
                      subtitle: '${data["model"]} (${data["brand"]})'),
                if (data.isNotEmpty)
                  AboutEntry('Android ${data["version"]["release"]}',
                      subtitle:
                          'API ${data["version"]["sdkInt"]}, ${data["version"]["securityPatch"]}'),
                if (data.isNotEmpty)
                  AboutEntry(context.strings.displayLabel,
                      subtitle:
                          '${data["displayMetrics"]["widthPx"]} x ${data["displayMetrics"]["heightPx"]}'),
              ];
              return RotaryList<AboutEntry>(entries,
                  tileBuilder: aboutTile,
                  title: context.strings.takeoutTitle,
                  subtitle: appVersion);
            }));
  }

  Widget aboutTile(BuildContext context, AboutEntry entry) {
    final title = Text(entry.title);
    final subtext = entry.subtitle;
    final subtitle = subtext != null ? Text(subtext) : null;
    return ListTile(onTap: entry.onTap, title: title, subtitle: subtitle);
  }

  String? downloadsSize(BuildContext context) {
    // caller watches state
    final size = context.trackCache.repository.cacheSize();
    return size > 0 ? storage(size) : null;
  }
}
