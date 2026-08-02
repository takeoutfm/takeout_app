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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'track_selection.dart';

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

  static void init() {
    MediaKit.ensureInitialized();
  }

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
  VideoController? controller;
  Player player = Player(configuration: PlayerConfiguration(libass: true));
  Exception? error;
  StreamSubscription<bool>? completedSubscription;
  StreamSubscription<bool>? playingSubscription;

  // static const _networkCachingMs = 2000;
  // static const _subtitlesFontSize = 30;

  // static const _height = 400.0;

  @override
  void initState() {
    super.initState();
    prepareController();
  }

  @override
  void dispose() {
    player.dispose();
    completedSubscription?.cancel();
    playingSubscription?.cancel();
    super.dispose();
  }

  Future<void> prepareController() async {
    final uri = await widget.mediaTrackResolver.resolve(widget.media);
    String url = uri.toString();
    if (url.startsWith('/api/')) {
      url = '${widget.settingsRepository.settings?.endpoint}$url';
    }
    final headers = widget.tokenRepository.addMediaToken();

    controller = VideoController(player);
    await player.setSubtitleTrack(SubtitleTrack.auto());

    completedSubscription = player.stream.completed.listen((completed) {
      print('completed $completed ${player.state.position}');
      if (completed) {
        widget.onPause?.call(player.state.position, player.state.duration);
      }
    });
    playingSubscription = player.stream.playing.listen((playing) {
      print('playing $playing ${player.state.position}');
      if (playing == false && player.state.duration > Duration.zero) {
        // false and zero can happen before or while loading so ignore
        widget.onPause?.call(player.state.position, player.state.duration);
      }
    });

    await player.open(
      Media(url, start: widget.startOffset, httpHeaders: headers),
    );

    setState(() {});
  }

  List<Widget> _topControls() => [
    MaterialCustomButton(
      onPressed: () async {
        // await player.stop();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      icon: Icon(Icons.arrow_back),
    ),
    const Spacer(),
    MaterialDesktopCustomButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text('Tracks'),
          children: [
            TrackSelection(player),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      ),
      icon: const Icon(Icons.settings),
    ),
  ];

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

    final videoController = controller;
    if (videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final topButtonBar = _topControls();
    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(topButtonBar: topButtonBar),
      fullscreen: MaterialVideoControlsThemeData(topButtonBar: topButtonBar),
      child: MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          topButtonBar: topButtonBar,
        ),
        fullscreen: MaterialDesktopVideoControlsThemeData(
          topButtonBar: topButtonBar,
        ),
        child: Scaffold(
          body: Video(
            controller: videoController,
            controls: MaterialDesktopVideoControls,
          ),
        ),
      ),
    );
  }
}
