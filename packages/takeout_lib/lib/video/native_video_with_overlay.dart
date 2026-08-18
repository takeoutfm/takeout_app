import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takeout_lib/video/source.dart';
import 'package:better_native_video_player/better_native_video_player.dart';
import 'native_video_overlay.dart';

class VideoWithOverlayScreen extends StatefulWidget {
  final VideoMedia video;
  final VideoSource source;
  final void Function(Duration, Duration)? onPause;

  const VideoWithOverlayScreen({
    super.key,
    required this.video,
    required this.source,
    this.onPause,
  });

  @override
  State<VideoWithOverlayScreen> createState() => _VideoWithOverlayScreenState();
}

class _VideoWithOverlayScreenState extends State<VideoWithOverlayScreen> {
  NativeVideoPlayerController? _controller;
  bool _disposed = false;
  Object? _error;

  bool _controlsVisible = true;
  Timer? _hideTimer;
  final FocusNode _screenFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
    _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (!_disposed) setState(() => _controlsVisible = false);
    });
  }

  void _revealControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _scheduleAutoHide();
  }

  void _holdControls() {
    _hideTimer?.cancel(); // stop the countdown entirely while dragging
    if (!_controlsVisible) setState(() => _controlsVisible = true);
  }

  void _releaseControls() {
    _scheduleAutoHide(); // resume the countdown once the drag ends
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = NativeVideoPlayerController(
        id: 1,
        autoPlay: true,
        lockToLandscape: false,
        showNativeControls: false,
        mediaInfo: NativeVideoPlayerMediaInfo(
          title: widget.video.media.title,
          subtitle: widget.video.media.title,
          artworkUrl: widget.video.media.image,
        ),
      );

      if (_disposed) {
        await controller.dispose();
        return;
      }

      setState(() => _controller = controller);

      await controller.initialize();
      if (_disposed) {
        await controller.dispose();
        return;
      }

      await controller.load(
        url: widget.source.url,
        headers: widget.source.headers,
        startAt: widget.video.startOffset,
      );

      final subtitles = await controller.getAvailableSubtitleTracks();
      final selectedTrack = subtitles.firstOrNull;
      if (selectedTrack != null) {
        await controller.setSubtitleTrack(selectedTrack);
      }
    } catch (e, st) {
      print('INIT FAILED: $e');
      print(st);
      if (!_disposed) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // TODO
    _hideTimer?.cancel();
    _controller?.dispose();
    _screenFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_error.toString()),
        ),
      );
    }

    final videoController = _controller;
    if (videoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Focus(
          focusNode: _screenFocusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;

            if (!_controlsVisible) {
              _revealControls();
              return KeyEventResult.handled;
            }

            _scheduleAutoHide();
            return KeyEventResult.ignored;
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  // catches taps even on "empty" transparent areas
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _revealControls();
                  },
                  child: ExcludeFocus(
                    excluding: true,
                    child: IgnorePointer(
                      child: NativeVideoPlayer(controller: videoController),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    // don't block child button taps
                    onTap: _scheduleAutoHide,
                    // just reset the timer, don't toggle visibility
                    child: AnimatedOpacity(
                      opacity: _controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: CustomVideoOverlay(
                        controller: videoController,
                        onPause: widget.onPause,
                        onUserInteraction: _scheduleAutoHide,
                        onSeekHoldStart: _holdControls,
                        onSeekHoldEnd: _releaseControls,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
