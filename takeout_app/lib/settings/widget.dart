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
import 'package:takeout_app/app/context.dart';
import 'package:takeout_lib/settings/model.dart';
import 'package:takeout_lib/settings/settings.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
      return Scaffold(
          appBar: AppBar(title: Text(context.strings.settingsLabel)),
          body: Column(children: [
            Card(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(context.strings.settingHomeGridTitle),
                  subtitle: Text(context.strings.settingHomeGridSubtitle)),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                DropdownButton<HomeGridType>(
                    value: state.settings.homeGridType,
                    items: HomeGridType.values
                        .map((type) => DropdownMenuItem<HomeGridType>(
                            child: Text(_gridTypeText(context, type)),
                            value: type))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.settings.homeGridType = value;
                      }
                    })
              ])
            ])),
            Card(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              _switchTile(
                  Icons.cloud_outlined,
                  context.strings.settingStreamingTitle,
                  context.strings.settingStreamingSubtitle,
                  state.settings.allowMobileStreaming, (value) {
                context.settings.allowStreaming = value;
              }),
              _switchTile(
                  Icons.cloud_download_outlined,
                  context.strings.settingDownloadsTitle,
                  context.strings.settingDownloadsSubtitle,
                  state.settings.allowMobileDownload, (value) {
                context.settings.allowDownload = value;
              }),
              _switchTile(
                  Icons.image_outlined,
                  context.strings.settingArtworkTitle,
                  context.strings.settingArtworkSubtitle,
                  state.settings.allowMobileArtistArtwork, (value) {
                context.settings.allowArtistArtwork = value;
              }),
            ]))
          ]));
    });
  }

  String _gridTypeText(BuildContext context, HomeGridType type) {
    switch (type) {
      case HomeGridType.mix:
        return context.strings.settingHomeGridMix;
      case HomeGridType.downloads:
        return context.strings.settingHomeGridDownloads;
      case HomeGridType.added:
        return context.strings.settingHomeGridAdded;
      case HomeGridType.released:
        return context.strings.settingHomeGridReleased;
    }
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
