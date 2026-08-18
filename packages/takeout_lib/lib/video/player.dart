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
    required VideoMedia media,
    void Function(Duration, Duration)? onPause,
    Key? key,
  }) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return MediaKitVideoPlayer(media: media, onPause: onPause, key: key);
    }
    return NativeVideoPlayer(media: media, onPause: onPause, key: key);
  }

  static void init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      MediaKitVideoPlayer.init();
    }
  }

  final VideoMedia media;
  final void Function(Duration, Duration)? onPause;

  const VideoPlayer({required this.media, this.onPause, super.key});
}
