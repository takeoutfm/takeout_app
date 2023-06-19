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

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final MovieView state;
  final MediaTrack movie;
  final MediaTrackResolver mediaTrackResolver;
  final TokenRepository tokenRepository;
  final SettingsRepository settingsRepository;
  final Duration? startOffset;
  final bool autoPlay;
  final bool allowedScreenSleep;
  final bool fullScreenByDefault;
  final Function(Duration, Duration)? onPause;

  VideoPlayer(this.state,
      {required this.mediaTrackResolver,
      required this.tokenRepository,
      required this.settingsRepository,
      this.startOffset,
      this.autoPlay = true,
      this.allowedScreenSleep = false,
      this.fullScreenByDefault = true,
      this.onPause,
      super.key})
      : movie = _MovieMediaTrack(state);

  @override
  State<VideoPlayer> createState() => VideoPlayerState();
}

class VideoPlayerState extends State<VideoPlayer> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

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
    final uri = await widget.mediaTrackResolver.resolve(widget.movie);
    String url = uri.toString();
    if (url.startsWith('/api/')) {
      url = '${widget.settingsRepository.settings?.endpoint}$url';
    }
    final headers = widget.tokenRepository.addMediaToken();
    final controller = VideoPlayerController.network(url, httpHeaders: headers);
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final controller = ChewieController(
      allowedScreenSleep: widget.allowedScreenSleep,
      autoPlay: widget.autoPlay,
      fullScreenByDefault: widget.fullScreenByDefault,
      startAt: widget.startOffset,
      videoPlayerController: videoPlayerController!,
    );
    chewieController = controller;
    return Chewie(controller: controller);
  }
}

// TODO add location back to movie to avoid this hassle?
class _MovieMediaTrack implements MediaTrack {
  MovieView view;

  _MovieMediaTrack(this.view);

  @override
  String get creator => '';

  @override
  String get album => '';

  @override
  String get image => view.movie.image;

  @override
  int get year => 0;

  @override
  String get title => view.movie.title;

  @override
  String get etag => view.movie.etag;

  @override
  int get size => view.movie.size;

  @override
  int get number => 0;

  @override
  int get disc => 0;

  @override
  String get date => view.movie.date;

  @override
  String get location => view.location;
}
