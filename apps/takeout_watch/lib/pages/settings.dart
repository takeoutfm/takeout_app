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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/nav.dart';
import 'package:takeout_watch/pages/about.dart';
import 'package:takeout_watch/platform.dart';
import 'package:takeout_watch/widgets/dialog.dart';
import 'package:takeout_watch/widgets/list.dart';

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
    final entries = [
      SettingEntry<bool>(context.strings.settingAutoPlay, toggleAutoPlay,
          icon: const Icon(Icons.play_arrow),
          currentValue: (state) => state.settings.autoPlay),
      SettingEntry<bool>(context.strings.settingAutoCache, toggleAutoCache,
          icon: const Icon(Icons.cloud_download_outlined),
          currentValue: (state) => state.settings.autoCache),
      SettingEntry<MusicType>(context.strings.musicSortType, nextMusicType,
          icon: const Icon(Icons.sort),
          currentValue: (_) => context.selectedMediaType.state.musicType),
      SettingEntry<FilmType>(context.strings.filmSortType, nextFilmType,
          icon: const Icon(Icons.sort),
          currentValue: (_) => context.selectedMediaType.state.filmType),
      SettingEntry<PodcastType>(
          context.strings.podcastSortType, nextPodcastType,
          icon: const Icon(Icons.sort),
          currentValue: (_) => context.selectedMediaType.state.podcastType),
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
      SettingEntry<String>(
          context.strings.settingTrackActivity, toggleTrackActivity,
          icon: const Icon(Icons.share),
          currentValue: (state) =>
              state.settings.enableTrackActivity.settingValue(context)),
      SettingEntry<String>(
          context.strings.settingListenBrainz, toggleListenBrainz,
          icon: const Icon(Icons.hearing),
          currentValue: (state) =>
              state.settings.enableListenBrainz.settingValue(context)),
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
              body: RotaryList<SettingEntry<dynamic>>(entries,
                  title: context.strings.settingsLabel,
                  tileBuilder: (context, state) => settingTile(context, state,
                      subtitleTextStyle: textStyle)),
            ));
  }

  void nextMusicType(BuildContext context) {
    context.selectedMediaType.nextMusicType();
  }

  void nextFilmType(BuildContext context) {
    context.selectedMediaType.nextFilmType();
  }

  void nextPodcastType(BuildContext context) {
    context.selectedMediaType.nextPodcastType();
  }

  void toggleAutoPlay(BuildContext context) {
    context.settings.autoPlay = !context.settings.state.settings.autoPlay;
  }

  void toggleAutoCache(BuildContext context) {
    context.settings.autoCache = !context.settings.state.settings.autoCache;
  }

  void toggleMobileDownload(BuildContext context) {
    context.settings.allowDownload =
        !context.settings.state.settings.allowMobileDownload;
  }

  void toggleMobileStreaming(BuildContext context) {
    context.settings.allowStreaming =
        !context.settings.state.settings.allowMobileStreaming;
  }

  void toggleListenBrainz(BuildContext context) {
    context.settings.enabledListenBrainz =
        !context.settings.state.settings.enableListenBrainz;
  }

  void toggleTrackActivity(BuildContext context) {
    context.settings.enableTrackActivity =
        !context.settings.state.settings.enableTrackActivity;
  }

  void logout(BuildContext context) {
    confirmDialog(context,
            title: context.strings.confirmLogout,
            body: context.strings.logoutLabel)
        .then((confirmed) {
      if (confirmed != null && confirmed) {
        final context = globalAppKey.currentContext;
        if (context != null && context.mounted) {
          context.app.logout();
        }
      }
    });
  }

  Widget settingTile(BuildContext context, SettingEntry<dynamic> entry,
      {TextStyle? subtitleTextStyle}) {
    return Builder(builder: (BuildContext context) {
      final settings = context.watch<SettingsCubit>().state;
      final mediaType = context.watch<MediaTypeCubit>().state;
      String subtitle = '';
      if (entry.currentValue != null) {
        final value = entry.currentValue?.call(settings);
        if (value is bool) {
          subtitle = value.settingValue(context);
        } else if (value is MusicType) {
          subtitle = value.settingValue(mediaType);
        } else if (value is FilmType) {
          subtitle = value.settingValue(mediaType);
        } else if (value is PodcastType) {
          subtitle = value.settingValue(mediaType);
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
    });
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

extension SettingMusicType on MusicType {
  String settingValue(MediaTypeState state) => state.musicType.name;
}

extension SettingFilmType on FilmType {
  String settingValue(MediaTypeState state) => state.filmType.name;
}

extension SettingPodcastType on PodcastType {
  String settingValue(MediaTypeState state) => state.podcastType.name;
}
