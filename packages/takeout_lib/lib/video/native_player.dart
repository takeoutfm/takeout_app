// Copyright 2026 defsub
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:takeout_lib/video/source.dart';
import 'package:takeout_lib/video/native_video_with_overlay.dart';
import 'player.dart';

class NativeVideoPlayer extends VideoPlayer {
  const NativeVideoPlayer({required super.media, super.onPause, super.key});

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  VideoSource? _source;

  @override
  void initState() {
    super.initState();
    prepareController();
  }

  Future<void> prepareController() async {
    final source = await widget.media.resolve();
    setState(() {
      _source = source;
    });
  }

  @override
  Widget build(BuildContext context) {
    final source = _source;
    if (source == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return VideoWithOverlayScreen(
      video: widget.media,
      source: source,
      onPause: widget.onPause,
    );
  }
}
