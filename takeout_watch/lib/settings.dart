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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_lib/settings/model.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/platform.dart';

import 'about.dart';
import 'dialog.dart';
import 'list.dart';

class SettingEntry<T> {
  final String name;
  final Widget? icon;
  final void Function(BuildContext) onSelected;
  final T Function(SettingsState)? currentValue;

  SettingEntry(this.name, this.onSelected, {this.icon, this.currentValue});
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityCubit>().state;
    final entries = [
      SettingEntry<bool>(context.strings.settingAutoplay, toggleAutoplay,
          icon: const Icon(Icons.play_arrow),
          currentValue: (state) => state.settings.autoplay),
      SettingEntry<HomeGridType>(
          context.strings.settingsMediaSort, nextHomeGridType,
          icon: const Icon(Icons.sort),
          currentValue: (state) => state.settings.homeGridType),
      SettingEntry<String>(
          context.strings.settingMobileDownloads, toggleMobileDownload,
          icon: const Icon(Icons.cloud_download_outlined),
          currentValue: (state) =>
              state.settings.allowMobileDownload.settingValue(context)),
      SettingEntry<String>(
          context.strings.settingMobileStreaming, toggleMobileStreaming,
          icon: const Icon(Icons.cloud_outlined),
          currentValue: (state) =>
              state.settings.allowMobileStreaming.settingValue(context)),
      SettingEntry<void>(context.strings.soundLabel, onSound,
          icon: const Icon(Icons.volume_up)),
      SettingEntry<void>(context.strings.bluetoothLabel, onBluetooth,
          icon: const Icon(Icons.bluetooth)),
      if (context.app.state.authenticated)
        SettingEntry<String>(context.strings.logoutLabel, logout,
            icon: const Icon(Icons.logout),
            currentValue: (state) => state.settings.host),
      SettingEntry<void>(context.strings.aboutLabel, onAbout,
          icon: const Icon(Icons.info_outline)),
    ];

    // TODO blue isn't working
    const subtitleColor = Colors.blueAccent;
    var textStyle = context.listTileTheme.subtitleTextStyle;
    textStyle ??= textStyle?.copyWith(color: subtitleColor);

    return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => Scaffold(
              body: RotaryList<SettingEntry>(entries,
                  title: context.strings.settingsLabel,
                  tileBuilder: (context, state) => settingTile(context, state,
                      subtitleTextStyle: textStyle)),
            ));
  }

  void nextHomeGridType(BuildContext context) {
    final nextType =
        context.settings.state.settings.homeGridType == HomeGridType.added
            ? HomeGridType.released
            : HomeGridType.added;
    context.settings.homeGridType = nextType;
  }

  void toggleAutoplay(BuildContext context) {
    context.settings.autoplay = !context.settings.state.settings.autoplay;
  }

  void toggleMobileDownload(BuildContext context) {
    context.settings.allowDownload =
        !context.settings.state.settings.allowMobileDownload;
  }

  void toggleMobileStreaming(BuildContext context) {
    context.settings.allowStreaming =
        !context.settings.state.settings.allowMobileStreaming;
  }

  void logout(BuildContext context) {
    confirmDialog(context,
            title: context.strings.confirmLogout,
            body: context.strings.logoutLabel)
        .then((confirmed) {
      if (confirmed != null && confirmed) {
        context.app.logout();
      }
    });
  }

  Widget settingTile(BuildContext context, SettingEntry entry,
      {TextStyle? subtitleTextStyle}) {
    final settings = context.watch<SettingsCubit>().state;
    String subtitle = '';
    if (entry.currentValue != null) {
      final value = entry.currentValue?.call(settings);
      if (value is bool) {
        subtitle = value.settingValue(context);
      } else if (value is HomeGridType) {
        subtitle = value.settingValue(context);
      } else {
        subtitle = value.toString();
      }
    }
    return ListTile(
        leading: entry.icon,
        title: Text(entry.name),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        subtitleTextStyle: subtitleTextStyle,
        onTap: () => entry.onSelected(context));
  }

  void onAbout(BuildContext context) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => const AboutPage()));
  }

  void onSound(BuildContext context) {
    platformSoundSettings();
  }

  void onBluetooth(BuildContext context) {
    platformBluetoothSettings();
  }
}

bool allowStreaming(BuildContext context) {
  final connectivity = context.connectivity.state;
  final settingAllowed = context.settings.state.settings.allowMobileStreaming;
  return connectivity.mobile ? settingAllowed : true;
}

bool allowDownload(BuildContext context) {
  final connectivity = context.connectivity.state;
  final settingAllowed = context.settings.state.settings.allowMobileDownload;
  return connectivity.mobile ? settingAllowed : true;
}

extension SettingBool on bool {
  String settingValue(BuildContext context) {
    return this
        ? context.strings.settingEnabled
        : context.strings.settingDisabled;
  }
}

extension SettingHomeGridType on HomeGridType {
  String settingValue(BuildContext context) {
    if (this == HomeGridType.added || this == HomeGridType.mix) {
      return context.strings.settingHomeGridAdded;
    } else if (this == HomeGridType.released) {
      return context.strings.settingHomeGridReleased;
    }
    return 'Unknown';
  }
}
