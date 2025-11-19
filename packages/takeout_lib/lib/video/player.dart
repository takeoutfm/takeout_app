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

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final MediaTrack media;
  final MediaTrackResolver mediaTrackResolver;
  final TokenRepository tokenRepository;
  final SettingsRepository settingsRepository;
  final Duration? startOffset;
  final bool autoPlay;
  final bool allowedScreenSleep;
  final bool fullScreenByDefault;
  final void Function(Duration, Duration)? onPause;

  const VideoPlayer(
    this.media, {
    required this.mediaTrackResolver,
    required this.tokenRepository,
    required this.settingsRepository,
    this.startOffset,
    this.autoPlay = true,
    this.allowedScreenSleep = false,
    this.fullScreenByDefault = true,
    this.onPause,
    super.key,
  });

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Exception? error;

  @override
  void initState() {
    super.initState();
    prepareController();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  Future<void> prepareController() async {
    final uri = await widget.mediaTrackResolver.resolve(widget.media);
    String url = uri.toString();
    if (url.startsWith('/api/')) {
      url = '${widget.settingsRepository.settings?.endpoint}$url';
    }
    final headers = widget.tokenRepository.addMediaToken();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: headers,
    );
    try {
      await controller.initialize();
      controller.addListener(() {
        final value = controller.value;
        if (value.isInitialized) {
          if (value.isPlaying == false) {
            widget.onPause?.call(value.position, value.duration);
          }
        }
      });
      videoPlayerController = controller;

      chewieController = ChewieController(
        allowedScreenSleep: widget.allowedScreenSleep,
        autoPlay: widget.autoPlay,
        fullScreenByDefault: widget.fullScreenByDefault,
        startAt: widget.startOffset,
        videoPlayerController: videoPlayerController!,
      );
    } on Exception catch (e) {
      error = e;
    }
    setState(() {});
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
    if (videoPlayerController == null || chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Chewie(controller: chewieController!);
  }
}
