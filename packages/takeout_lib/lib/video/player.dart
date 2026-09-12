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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:takeout_lib/video/media_kit_player.dart';
import 'package:takeout_lib/video/native_player.dart';
import 'package:takeout_lib/video/source.dart';

abstract class VideoPlayer extends StatefulWidget {
  factory VideoPlayer.create({
    required PlayerState state,
    void Function(Duration, Duration)? onPause,
    void Function(int)? onAudioTrackChange,
    void Function(int)? onSubtitleTrackChange,
    Key? key,
  }) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return MediaKitVideoPlayer(state: state, onPause: onPause, key: key);
    }
    return NativeVideoPlayer(
      state: state,
      onPause: onPause,
      onAudioTrackChange: onAudioTrackChange,
      onSubtitleTrackChange: onSubtitleTrackChange,
      key: key,
    );
  }

  static void init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      MediaKitVideoPlayer.init();
    }
  }

  final PlayerState state;
  final void Function(Duration, Duration)? onPause;
  final void Function(int)? onAudioTrackChange;
  final void Function(int)? onSubtitleTrackChange;

  const VideoPlayer({
    required this.state,
    this.onPause,
    this.onAudioTrackChange,
    this.onSubtitleTrackChange,
    super.key,
  });
}
