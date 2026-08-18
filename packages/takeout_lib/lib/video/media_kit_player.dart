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
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:takeout_lib/video/media_kit_controls.dart';
import 'player.dart';

class MediaKitVideoPlayer extends VideoPlayer {
  const MediaKitVideoPlayer({required super.media, super.onPause, super.key});

  @override
  State<MediaKitVideoPlayer> createState() => _DesktopVideoPlayerState();

  static void init() {
    MediaKit.ensureInitialized();
  }
}

class _DesktopVideoPlayerState extends State<MediaKitVideoPlayer> {
  final Player _player = Player(
    configuration: PlayerConfiguration(libass: true),
  );
  VideoController? _controller;
  Exception? error;
  StreamSubscription<bool>? _completedSubscription;
  StreamSubscription<bool>? _playingSubscription;

  @override
  void initState() {
    super.initState();
    prepareController();
  }

  @override
  void dispose() {
    _player.dispose();
    _completedSubscription?.cancel();
    _playingSubscription?.cancel();
    super.dispose();
  }

  Future<void> prepareController() async {
    final source = await widget.media.resolve();
    final controller = VideoController(_player);

    _completedSubscription = _player.stream.completed.listen((completed) {
      if (completed) {
        widget.onPause?.call(_player.state.position, _player.state.duration);
      }
    });

    _playingSubscription = _player.stream.playing.listen((playing) {
      if (playing == false && _player.state.duration > Duration.zero) {
        // false and zero can happen before or while loading so ignore
        widget.onPause?.call(_player.state.position, _player.state.duration);
      }
    });

    await _player.open(
      Media(
        source.url,
        start: widget.media.startOffset,
        httpHeaders: source.headers,
      ),
    );
    await _player.setSubtitleTrack(SubtitleTrack.auto());

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(error!.toString()),
        ),
      );
    }

    final videoController = _controller;
    if (videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final video = Video(
      controller: videoController,
      controls: AdaptiveVideoControls,
    );
    return Scaffold(body: withControls(context, video));
  }
}
