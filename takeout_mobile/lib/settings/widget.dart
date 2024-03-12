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
import 'package:takeout_lib/settings/settings.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
      return Scaffold(
          appBar: AppBar(title: Text(context.strings.settingsLabel)),
          body: SingleChildScrollView(
              child: Column(children: [
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
            ])),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _switchTile(
                      Icons.share,
                      context.strings.settingTrackActivityTitle,
                      context.strings.settingTrackActivitySubtitle,
                      state.settings.enableTrackActivity, (value) {
                    context.settings.enableTrackActivity = value;
                  }),
                ],
              ),
            ),
            Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.key),
                  title: Text(context.strings.settingListenBrainzToken),
                  subtitle: _TokenField(state),
                  trailing: Switch(
                    value: state.settings.enableListenBrainz,
                    onChanged: (value) {
                      context.settings.enabledListenBrainz = value;
                    },
                  ),
                ),
              ],
            )),
          ])));
    });
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

class _TokenField extends StatefulWidget {
  final SettingsState state;

  const _TokenField(this.state);

  @override
  State createState() => _TokenFieldState();
}

class _TokenFieldState extends State<_TokenField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      onTap: () {
        setState(() {
          _obscureText = false;
        });
      },
      onTapOutside: (_) {
        setState(() {
          _obscureText = true;
        });
      },
      onChanged: (value) {
        context.settings.listenBrainzToken = value.trim();
      },
      initialValue: widget.state.settings.listenBrainzToken,
      // decoration: const InputDecoration(
      //   border: OutlineInputBorder(),
      // ),
    );
  }
}
