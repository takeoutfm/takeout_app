import 'dart:async';

import 'package:better_native_video_player/better_native_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takeout_lib/video/video_progress_bar.dart';
import 'native_audio_picker.dart';
import 'native_subtitle_picker.dart';

/// Custom video overlay with controls
///
/// This widget provides custom playback controls that overlay on top of the
/// native video player. Visibility/fade is managed by the parent screen
/// (VideoWithOverlayScreen), not by the native player's own overlay
/// mechanism, since that one is touch-only and doesn't support D-pad.
///
/// D-pad navigation is handled entirely manually here (see
/// _handleRowNavigation) rather than relying on Flutter's default focus
/// traversal, because the embedded native video surface (a PlatformView)
/// sits outside Flutter's focus tree and can silently steal focus if
/// traversal is allowed to search past the edge of our controls.
class CustomVideoOverlay extends StatefulWidget {
  final void Function(Duration position, Duration duration)? onPause;
  final VoidCallback? onUserInteraction;
  final VoidCallback? onSeekHoldStart;
  final VoidCallback? onSeekHoldEnd;

  const CustomVideoOverlay({
    required this.controller,
    this.onUserInteraction,
    this.onSeekHoldStart,
    this.onSeekHoldEnd,
    this.onPause,
    super.key,
  });

  final NativeVideoPlayerController controller;

  @override
  State<CustomVideoOverlay> createState() => _CustomVideoOverlayState();
}

class _CustomVideoOverlayState extends State<CustomVideoOverlay> {
  bool _isSeeking = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  PlayerActivityState _activityState = PlayerActivityState.idle;
  bool _isAirPlayAvailable = false;
  bool _isAirPlayConnected = false;
  bool _isPipAvailable = false;
  List<NativeVideoPlayerQuality> _qualities = [];
  NativeVideoPlayerQuality? _currentQuality;
  double _currentSpeed = 1.0;
  double _subtitleFontSize = 16.0;

  // Stream subscriptions
  StreamSubscription<List<NativeVideoPlayerQuality>>? _qualitiesSubscription;
  StreamSubscription<Duration>? _bufferedPositionSubscription;
  StreamSubscription<bool>? _airPlayConnectedSubscription;
  StreamSubscription<bool>? _pipAvailableSubscription;

  // One FocusNode per actual interactive control, so D-pad navigation can
  // be driven by explicit identity checks rather than relying on Flutter's
  // default directional traversal (which is unreliable near the embedded
  // native video PlatformView).
  final FocusNode _backFocusNode = FocusNode();
  final FocusNode _pipFocusNode = FocusNode();
  final FocusNode _airplayFocusNode = FocusNode();

  final FocusNode _replayFocusNode = FocusNode();
  final FocusNode _playPauseFocusNode = FocusNode();
  final FocusNode _forwardFocusNode = FocusNode();

  final FocusNode _speedFocusNode = FocusNode();
  final FocusNode _qualityFocusNode = FocusNode();
  final FocusNode _subtitleFocusNode = FocusNode();
  final FocusNode _audioFocusNode = FocusNode();
  final FocusNode _progressFocusNode = FocusNode();

  // Available playback speeds
  static const List<double> _availableSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addActivityListener(_handleActivityEvent);
    widget.controller.addControlListener(_handleControlEvent);
    widget.controller.addAirPlayAvailabilityListener(
      _handleAirPlayAvailabilityChange,
    );

    // Get initial state
    _currentPosition = widget.controller.currentPosition;
    _duration = widget.controller.duration;
    _activityState = widget.controller.activityState;
    _qualities = widget.controller.qualities;
    _isPipAvailable = widget.controller.isPipAvailable;

    // Subscribe to qualities stream
    _qualitiesSubscription = widget.controller.qualitiesStream.listen(
      _handleQualitiesChanged,
    );

    // Subscribe to buffered position stream
    _bufferedPositionSubscription = widget.controller.bufferedPositionStream
        .listen(_handleBufferedPositionChanged);

    // Subscribe to AirPlay connection stream
    _airPlayConnectedSubscription = widget.controller.isAirplayConnectedStream
        .listen(_handleAirPlayConnectionChanged);

    // Subscribe to PiP availability stream
    _pipAvailableSubscription = widget.controller.isPipAvailableStream.listen(
      _handlePipAvailabilityChanged,
    );

    // Also check PiP availability once (for first load)
    _getPipAvailability();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playPauseFocusNode.requestFocus(); // start on play/pause
    });
  }

  void _handleQualitiesChanged(List<NativeVideoPlayerQuality> qualities) {
    if (!mounted) {
      return;
    }
    setState(() {
      _qualities = qualities;
    });
  }

  void _handleBufferedPositionChanged(Duration bufferedPosition) {
    if (!mounted || _isSeeking) {
      return;
    }
    setState(() {
      _bufferedPosition = bufferedPosition;
    });
  }

  void _getPipAvailability() async {
    final isAvailable = await widget.controller.isPictureInPictureAvailable();
    if (!mounted) {
      return;
    }
    setState(() {
      _isPipAvailable = isAvailable;
    });
  }

  void _handleAirPlayAvailabilityChange(bool isAvailable) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isAirPlayAvailable = isAvailable;
    });
  }

  void _handleAirPlayConnectionChanged(bool isConnected) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isAirPlayConnected = isConnected;
    });
  }

  void _handlePipAvailabilityChanged(bool isAvailable) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isPipAvailable = isAvailable;
    });
  }

  @override
  void dispose() {
    widget.controller.removeActivityListener(_handleActivityEvent);
    widget.controller.removeControlListener(_handleControlEvent);
    widget.controller.removeAirPlayAvailabilityListener(
      _handleAirPlayAvailabilityChange,
    );
    _qualitiesSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _airPlayConnectedSubscription?.cancel();
    _pipAvailableSubscription?.cancel();

    _backFocusNode.dispose();
    _pipFocusNode.dispose();
    _airplayFocusNode.dispose();
    _replayFocusNode.dispose();
    _playPauseFocusNode.dispose();
    _forwardFocusNode.dispose();
    _speedFocusNode.dispose();
    _qualityFocusNode.dispose();
    _subtitleFocusNode.dispose();
    _audioFocusNode.dispose();
    _progressFocusNode.dispose();

    super.dispose();
  }

  /// Builds the current grid of focusable controls, row by row, based on
  /// which optional buttons are currently visible. Used by
  /// _handleRowNavigation to figure out where to move focus next.
  List<List<FocusNode>> _currentRows() {
    final top = <FocusNode>[
      _backFocusNode,
      if (_isPipAvailable) _pipFocusNode,
      if (_isAirPlayAvailable) _airplayFocusNode,
    ];
    final center = <FocusNode>[
      _replayFocusNode,
      _playPauseFocusNode,
      _forwardFocusNode,
    ];
    final progress = <FocusNode>[_progressFocusNode];
    final bottom = <FocusNode>[
      _speedFocusNode,
      if (_qualities.isNotEmpty) _qualityFocusNode,
      _audioFocusNode,
      _subtitleFocusNode,
    ];
    return [top, center, progress, bottom];
  }

  /// Manually handles all four D-pad directions. Every arrow key is
  /// explicitly marked `handled`, even when there's nowhere further to move
  /// (e.g. pressing right on the rightmost button), so the key event never
  /// falls through to Flutter's default traversal and never leaks into the
  /// embedded native video PlatformView's own focus system.
  ///

  KeyEventResult _handleRowNavigation(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isArrow =
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight;
    if (!isArrow) return KeyEventResult.ignored;

    widget.onUserInteraction?.call(); // notify parent on every handled key

    final rows = _currentRows();
    final current = FocusManager.instance.primaryFocus;
    if (current == null) return KeyEventResult.handled;

    int rowIndex = -1;
    int colIndex = -1;
    for (var r = 0; r < rows.length; r++) {
      final c = rows[r].indexOf(current);
      if (c != -1) {
        rowIndex = r;
        colIndex = c;
        break;
      }
    }
    if (rowIndex == -1) return KeyEventResult.handled;

    final onProgressRow = current == _progressFocusNode;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (rowIndex < rows.length - 1) {
        final target = rows[rowIndex + 1];
        target[colIndex.clamp(0, target.length - 1)].requestFocus();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (rowIndex > 0) {
        final target = rows[rowIndex - 1];
        target[colIndex.clamp(0, target.length - 1)].requestFocus();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (onProgressRow) {
        _seekBy(const Duration(seconds: 10));
      } else {
        final row = rows[rowIndex];
        if (colIndex < row.length - 1) row[colIndex + 1].requestFocus();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (onProgressRow) {
        _seekBy(const Duration(seconds: -10));
      } else {
        final row = rows[rowIndex];
        if (colIndex > 0) row[colIndex - 1].requestFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _seekBy(Duration delta) {
    final target = _currentPosition + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);
    setState(() {
      _currentPosition =
          clamped; // update immediately for real-time UI feedback
    });
    widget.controller.seekTo(clamped);
  }

  void _handleActivityEvent(PlayerActivityEvent event) {
    if (!mounted) {
      return;
    }

    if (_activityState.isPlaying && event.state.isPaused) {
      // transition from playing to paused
      widget.onPause?.call(
        widget.controller.currentPosition,
        widget.controller.duration,
      );
    }

    setState(() {
      _activityState = event.state;
    });
  }

  void _handleControlEvent(PlayerControlEvent event) {
    if (!mounted) {
      return;
    }

    // Handle PiP availability changes
    if (event.state == PlayerControlState.pipAvailabilityChanged) {
      final isAvailable = event.data?['isAvailable'] as bool? ?? false;
      setState(() {
        _isPipAvailable = isAvailable;
      });
      return;
    }

    // Handle AirPlay availability changes
    if (event.state == PlayerControlState.airPlayAvailabilityChanged) {
      final isAvailable = event.data?['isAvailable'] as bool? ?? false;
      setState(() {
        _isAirPlayAvailable = isAvailable;
      });
      return;
    }

    if (event.state == PlayerControlState.timeUpdated) {
      final newPosition = widget.controller.currentPosition;
      if (_isSeeking) {
        return;
      }

      // If we have a target seek position, check if we've reached it
      // if (_targetSeekPosition != null) {
      //   // Consider the seek complete if we're within 200ms of the target
      //   final difference =
      //       (newPosition.inMilliseconds - _targetSeekPosition!.inMilliseconds)
      //           .abs();
      //   if (difference < 200) {
      //     // Seek completed, clear the flag and target
      //     setState(() {
      //       _isSeeking = false;
      //       _targetSeekPosition = null;
      //       _currentPosition = newPosition;
      //       _duration = widget.controller.duration;
      //     });
      //   }
      //   // Otherwise, ignore this update as it's likely an old position
      //   return;
      // }

      // Normal update when not seeking
      if (!_isSeeking) {
        setState(() {
          _currentPosition = newPosition;
          _duration = widget.controller.duration;
          // bufferedPosition is now handled by bufferedPositionStream
        });
      }
    } else if (event.state == PlayerControlState.qualityChanged) {
      // Update current quality (available qualities are handled by the stream)
      if (event.data != null && event.data!.containsKey('quality')) {
        setState(() {
          _currentQuality = NativeVideoPlayerQuality.fromMap(
            event.data!['quality'] as Map<dynamic, dynamic>,
          );
        });
      }
    } else if (event.state == PlayerControlState.speedChanged) {
      // Update current speed when it changes (e.g., from another overlay instance)
      if (event.data != null && event.data!.containsKey('speed')) {
        final speed = event.data!['speed'] as num;
        setState(() {
          _currentSpeed = speed.toDouble();
        });
      }
    }
  }

  // void _onSeekStart(double value) {
  //   setState(() {
  //     _isSeeking = true;
  //     _currentPosition = Duration(milliseconds: value.toInt());
  //   });
  // }
  //
  // void _onSeekChange(double value) {
  //   if (_isSeeking && _duration.inMilliseconds > 0) {
  //     setState(() {
  //       _currentPosition = Duration(milliseconds: value.toInt());
  //     });
  //   }
  // }
  //
  // void _onSeekEnd(double value) {
  //   final targetPosition = Duration(milliseconds: value.toInt());
  //   if (_duration.inMilliseconds > 0) {
  //     setState(() {
  //       // Store target position and keep _isSeeking true until we reach it
  //       _targetSeekPosition = targetPosition;
  //       _currentPosition = targetPosition; // Show target position immediately
  //     });
  //     widget.controller.seekTo(targetPosition);
  //   } else {
  //     setState(() {
  //       _isSeeking = false;
  //       _targetSeekPosition = null;
  //     });
  //   }
  // }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    // This outer Focus never takes focus itself (no focusNode/autofocus) —
    // it just needs to sit above every control so key events bubbling up
    // from whichever button currently has real focus pass through
    // _handleRowNavigation first, before Flutter's default traversal (or
    // native Android focus dispatch) can act on them.
    final stackWidget = Focus(
      onKeyEvent: _handleRowNavigation,
      child: Stack(
        children: [
          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  focusNode: _backFocusNode,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                // PiP button (only shown if available)
                if (_isPipAvailable)
                  IconButton(
                    focusNode: _pipFocusNode,
                    icon: const Icon(
                      Icons.picture_in_picture_alt,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await widget.controller.enterPictureInPicture();
                    },
                    tooltip: 'Picture in Picture',
                  ),
                // AirPlay button (only shown if available)
                if (_isAirPlayAvailable)
                  IconButton(
                    focusNode: _airplayFocusNode,
                    icon: Icon(
                      _isAirPlayConnected
                          ? Icons.cast_connected
                          : Icons.airplay,
                      color: _isAirPlayConnected ? Colors.blue : Colors.white,
                    ),
                    onPressed: () async {
                      await widget.controller.showAirPlayPicker();
                    },
                    tooltip: _isAirPlayConnected
                        ? 'AirPlay Connected'
                        : 'AirPlay',
                  ),
              ],
            ),
          ),

          // Control buttons
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip backward
                IconButton(
                  focusNode: _replayFocusNode,
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () {
                    widget.controller.seekTo(
                      _currentPosition - const Duration(seconds: 10),
                    );
                  },
                ),

                // Center play/pause button
                _buildPlayPauseButton(),

                // Skip forward
                IconButton(
                  focusNode: _forwardFocusNode,
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () {
                    widget.controller.seekTo(
                      _currentPosition + const Duration(seconds: 10),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar — its own focusable row now. Left/right seek
                // in fixed increments (handled entirely in
                // _handleRowNavigation via _seekBy), up/down leave the row
                // like any other row. The Slider itself has onChanged set
                // to null so it never engages its own internal arrow-key
                // handling — all seeking here is driven by us, not by the
                // Slider widget's default behavior.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    spacing: 8,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: VideoProgressBar(
                          focusNode: _progressFocusNode,
                          position: _currentPosition,
                          bufferedPosition: _bufferedPosition,
                          duration: _duration,
                          onSeekPreview: (pos) {
                            setState(() => _currentPosition = pos);
                          },
                          onSeekCommit: (pos) {
                            setState(() {
                              _currentPosition = pos;
                              _isSeeking = false;
                            });
                            widget.controller.seekTo(pos);
                          },
                          onDragStart: () {
                            _isSeeking = true;
                            widget.onSeekHoldStart?.call();
                          },
                          onDragEnd: widget.onSeekHoldEnd,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Speed / quality / subtitle — separate row below the
                // progress bar.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [
                      TextButton(
                        focusNode: _speedFocusNode,
                        onPressed: _showSpeedSelector,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '${_currentSpeed}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (_qualities.isNotEmpty)
                        TextButton(
                          focusNode: _qualityFocusNode,
                          onPressed: _showQualitySelector,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _currentQuality?.label ?? 'Auto',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      IconButton(
                        focusNode: _audioFocusNode, // new node, add to _currentRows()
                        icon: const Icon(Icons.audiotrack, color: Colors.white),
                        onPressed: _showAudioTrackPicker,
                        tooltip: 'Audio',
                      ),
                      IconButton(
                        focusNode: _subtitleFocusNode,
                        icon: const Icon(
                          Icons.closed_caption,
                          color: Colors.white,
                        ),
                        onPressed: _showSubtitlePicker,
                        tooltip: 'Subtitles',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(child: stackWidget),
    );
  }

  Widget _buildPlayPauseButton() {
    // Show loading indicator when buffering or loading
    if (_activityState == PlayerActivityState.buffering ||
        _activityState == PlayerActivityState.loading) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    // Show play/pause button for other states
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        focusNode: _playPauseFocusNode,
        icon: Icon(
          _activityState.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
        ),
        onPressed: () {
          if (_activityState.isPlaying) {
            widget.controller.pause();
          } else {
            widget.controller.play();
          }
        },
      ),
    );
  }

  /// Shows the quality selector modal
  void _showQualitySelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black87,
      useRootNavigator: false,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Quality',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _qualities.map((quality) {
                    final isSelected = _currentQuality?.label == quality.label;
                    return ListTile(
                      title: Text(
                        quality.label,
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: quality.bitrate != null
                          ? Text(
                              '${quality.width ?? '?'}x${quality.height ?? '?'} - ${(quality.bitrate! / 1000000).toStringAsFixed(2)} Mbps',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.red.withValues(alpha: 0.7)
                                    : Colors.white70,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.red)
                          : null,
                      onTap: () {
                        widget.controller.setQuality(quality);
                        Navigator.pop(context);
                        if (mounted) {
                          setState(() {
                            _currentQuality = quality;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows the speed selector modal
  void _showSpeedSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black87,
      useRootNavigator: false,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Playback Speed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _availableSpeeds.map((speed) {
                    final isSelected = _currentSpeed == speed;
                    return ListTile(
                      title: Text(
                        '${speed}x',
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        speed == 1.0
                            ? 'Normal'
                            : speed < 1.0
                            ? 'Slower'
                            : 'Faster',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.red.withValues(alpha: 0.7)
                              : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.red)
                          : null,
                      onTap: () async {
                        await widget.controller.setSpeed(speed);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (mounted) {
                          setState(() {
                            _currentSpeed = speed;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows the subtitle picker modal
  void _showSubtitlePicker() {
    showSubtitlePicker(
      context: context,
      controller: widget.controller,
      fontSize: _subtitleFontSize,
      onFontSizeChanged: (newSize) {
        if (mounted) {
          setState(() {
            _subtitleFontSize = newSize;
          });
        }
      },
    );
  }

  void _showAudioTrackPicker() {
    showAudioTrackPicker(
      context: context,
      controller: widget.controller,
    );
  }
}

// import 'dart:async';
//
// import 'package:better_native_video_player/better_native_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'subtitle_picker_modal.dart';
//
// /// Custom video overlay with controls
// ///
// /// This widget provides custom playback controls that overlay on top of the native video player.
// /// The visibility and fade animations are handled by the parent NativeVideoPlayer widget.
// class CustomVideoOverlay extends StatefulWidget {
//   final void Function(Duration position, Duration duration)? onPause;
//
//   const CustomVideoOverlay({required this.controller, this.onPause, super.key});
//
//   final NativeVideoPlayerController controller;
//
//   @override
//   State<CustomVideoOverlay> createState() => _CustomVideoOverlayState();
// }
//
// class _CustomVideoOverlayState extends State<CustomVideoOverlay> {
//   bool _isSeeking = false;
//   Duration? _targetSeekPosition; // Track where we're seeking to
//   Duration _currentPosition = Duration.zero;
//   Duration _duration = Duration.zero;
//   Duration _bufferedPosition = Duration.zero;
//   PlayerActivityState _activityState = PlayerActivityState.idle;
//   bool _isAirPlayAvailable = false;
//   bool _isAirPlayConnected = false;
//   bool _isPipAvailable = false;
//   List<NativeVideoPlayerQuality> _qualities = [];
//   NativeVideoPlayerQuality? _currentQuality;
//   double _currentSpeed = 1.0;
//   double _subtitleFontSize = 16.0;
//
//   // Stream subscriptions
//   StreamSubscription<List<NativeVideoPlayerQuality>>? _qualitiesSubscription;
//   StreamSubscription<Duration>? _bufferedPositionSubscription;
//   StreamSubscription<bool>? _airPlayConnectedSubscription;
//   StreamSubscription<bool>? _pipAvailableSubscription;
//
//   final FocusNode _topRowFocusNode =
//       FocusNode(); // e.g. back button, or PiP/AirPlay
//   final FocusNode _centerRowFocusNode = FocusNode(); // play/pause
//   final FocusNode _bottomRowFocusNode =
//       FocusNode(); // progress bar / subtitle button
//
//   // Available playback speeds
//   static const List<double> _availableSpeeds = [
//     0.25,
//     0.5,
//     0.75,
//     1.0,
//     1.25,
//     1.5,
//     1.75,
//     2.0,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addActivityListener(_handleActivityEvent);
//     widget.controller.addControlListener(_handleControlEvent);
//     widget.controller.addAirPlayAvailabilityListener(
//       _handleAirPlayAvailabilityChange,
//     );
//
//     // Get initial state
//     _currentPosition = widget.controller.currentPosition;
//     _duration = widget.controller.duration;
//     _activityState = widget.controller.activityState;
//     _qualities = widget.controller.qualities;
//     _isPipAvailable = widget.controller.isPipAvailable;
//
//     // Subscribe to qualities stream
//     _qualitiesSubscription = widget.controller.qualitiesStream.listen(
//       _handleQualitiesChanged,
//     );
//
//     // Subscribe to buffered position stream
//     _bufferedPositionSubscription = widget.controller.bufferedPositionStream
//         .listen(_handleBufferedPositionChanged);
//
//     // Subscribe to AirPlay connection stream
//     _airPlayConnectedSubscription = widget.controller.isAirplayConnectedStream
//         .listen(_handleAirPlayConnectionChanged);
//
//     // Subscribe to PiP availability stream
//     _pipAvailableSubscription = widget.controller.isPipAvailableStream.listen(
//       _handlePipAvailabilityChanged,
//     );
//
//     // Also check PiP availability once (for first load)
//     _getPipAvailability();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _centerRowFocusNode.requestFocus(); // start on play/pause
//     });
//   }
//
//   // void _onPlayPauseFocusChange() {
//   //   if (!_playPauseFocusNode.hasFocus && mounted) {
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       if (mounted) _playPauseFocusNode.requestFocus();
//   //     });
//   //   }
//   // }
//
//   void _handleQualitiesChanged(List<NativeVideoPlayerQuality> qualities) {
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       _qualities = qualities;
//     });
//   }
//
//   void _handleBufferedPositionChanged(Duration bufferedPosition) {
//     if (!mounted || _isSeeking) {
//       return;
//     }
//     setState(() {
//       _bufferedPosition = bufferedPosition;
//     });
//   }
//
//   void _getPipAvailability() async {
//     final isAvailable = await widget.controller.isPictureInPictureAvailable();
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       _isPipAvailable = isAvailable;
//     });
//   }
//
//   void _handleAirPlayAvailabilityChange(bool isAvailable) {
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       _isAirPlayAvailable = isAvailable;
//     });
//   }
//
//   void _handleAirPlayConnectionChanged(bool isConnected) {
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       _isAirPlayConnected = isConnected;
//     });
//   }
//
//   void _handlePipAvailabilityChanged(bool isAvailable) {
//     if (!mounted) {
//       return;
//     }
//     setState(() {
//       _isPipAvailable = isAvailable;
//     });
//   }
//
//   @override
//   void dispose() {
//     widget.controller.removeActivityListener(_handleActivityEvent);
//     widget.controller.removeControlListener(_handleControlEvent);
//     widget.controller.removeAirPlayAvailabilityListener(
//       _handleAirPlayAvailabilityChange,
//     );
//     _qualitiesSubscription?.cancel();
//     _bufferedPositionSubscription?.cancel();
//     _airPlayConnectedSubscription?.cancel();
//     _pipAvailableSubscription?.cancel();
//     _topRowFocusNode.dispose();
//     _centerRowFocusNode.dispose();
//     _bottomRowFocusNode.dispose();
//     super.dispose();
//   }
//
//   KeyEventResult _handleRowNavigation(FocusNode node, KeyEvent event) {
//     if (event is! KeyDownEvent) return KeyEventResult.ignored;
//
//     if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//       if (node == _topRowFocusNode) {
//         _centerRowFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (node == _centerRowFocusNode) {
//         _bottomRowFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       // already on bottom row — nowhere to go, swallow so it
//       // doesn't escape to the native view
//       return KeyEventResult.handled;
//     }
//
//     if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//       if (node == _bottomRowFocusNode) {
//         _centerRowFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       if (node == _centerRowFocusNode) {
//         _topRowFocusNode.requestFocus();
//         return KeyEventResult.handled;
//       }
//       return KeyEventResult.handled; // already on top row
//     }
//
//     return KeyEventResult
//         .ignored; // let left/right fall through to normal traversal
//   }
//
//   void _handleActivityEvent(PlayerActivityEvent event) {
//     if (!mounted) {
//       return;
//     }
//
//     print('actev ${_activityState.isPlaying} ${event.state.isPaused}');
//     if (_activityState.isPlaying && event.state.isPaused) {
//       // transition from playing to paused
//       print(
//         '${widget.onPause} calling onPause ${widget.controller.currentPosition}',
//       );
//       widget.onPause?.call(
//         widget.controller.currentPosition,
//         widget.controller.duration,
//       );
//     }
//
//     setState(() {
//       _activityState = event.state;
//     });
//   }
//
//   void _handleControlEvent(PlayerControlEvent event) {
//     if (!mounted) {
//       return;
//     }
//
//     // Handle PiP availability changes
//     if (event.state == PlayerControlState.pipAvailabilityChanged) {
//       final isAvailable = event.data?['isAvailable'] as bool? ?? false;
//       setState(() {
//         _isPipAvailable = isAvailable;
//       });
//       return;
//     }
//
//     // Handle AirPlay availability changes
//     if (event.state == PlayerControlState.airPlayAvailabilityChanged) {
//       final isAvailable = event.data?['isAvailable'] as bool? ?? false;
//       setState(() {
//         _isAirPlayAvailable = isAvailable;
//       });
//       return;
//     }
//
//     if (event.state == PlayerControlState.timeUpdated) {
//       final newPosition = widget.controller.currentPosition;
//
//       // If we have a target seek position, check if we've reached it
//       if (_targetSeekPosition != null) {
//         // Consider the seek complete if we're within 200ms of the target
//         final difference =
//             (newPosition.inMilliseconds - _targetSeekPosition!.inMilliseconds)
//                 .abs();
//         if (difference < 200) {
//           // Seek completed, clear the flag and target
//           setState(() {
//             _isSeeking = false;
//             _targetSeekPosition = null;
//             _currentPosition = newPosition;
//             _duration = widget.controller.duration;
//           });
//         }
//         // Otherwise, ignore this update as it's likely an old position
//         return;
//       }
//
//       // Normal update when not seeking
//       if (!_isSeeking) {
//         setState(() {
//           _currentPosition = newPosition;
//           _duration = widget.controller.duration;
//           // bufferedPosition is now handled by bufferedPositionStream
//         });
//       }
//     } else if (event.state == PlayerControlState.qualityChanged) {
//       // Update current quality (available qualities are handled by the stream)
//       if (event.data != null && event.data!.containsKey('quality')) {
//         setState(() {
//           _currentQuality = NativeVideoPlayerQuality.fromMap(
//             event.data!['quality'] as Map<dynamic, dynamic>,
//           );
//         });
//       }
//     } else if (event.state == PlayerControlState.speedChanged) {
//       // Update current speed when it changes (e.g., from another overlay instance)
//       if (event.data != null && event.data!.containsKey('speed')) {
//         final speed = event.data!['speed'] as num;
//         setState(() {
//           _currentSpeed = speed.toDouble();
//         });
//       }
//     }
//     // else if (event.state == PlayerControlState.fullscreenEntered ||
//     //     event.state == PlayerControlState.fullscreenExited) {
//     //   // Trigger rebuild when fullscreen state changes so controls visibility updates
//     //   setState(() {
//     //     // No state to update, just trigger rebuild to update conditional UI elements
//     //   });
//     // }
//   }
//
//   void _onSeekStart(double value) {
//     setState(() {
//       _isSeeking = true;
//       _currentPosition = Duration(milliseconds: value.toInt());
//     });
//   }
//
//   void _onSeekChange(double value) {
//     if (_isSeeking && _duration.inMilliseconds > 0) {
//       setState(() {
//         _currentPosition = Duration(milliseconds: value.toInt());
//       });
//     }
//   }
//
//   void _onSeekEnd(double value) {
//     final targetPosition = Duration(milliseconds: value.toInt());
//     if (_duration.inMilliseconds > 0) {
//       setState(() {
//         // Store target position and keep _isSeeking true until we reach it
//         _targetSeekPosition = targetPosition;
//         _currentPosition = targetPosition; // Show target position immediately
//       });
//       widget.controller.seekTo(targetPosition);
//     } else {
//       setState(() {
//         _isSeeking = false;
//         _targetSeekPosition = null;
//       });
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);
//
//     if (hours > 0) {
//       return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
//     }
//     return '${twoDigits(minutes)}:${twoDigits(seconds)}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final stackWidget = Focus(
//       // no focusNode/autofocus here — this node never takes focus itself,
//       // it just needs to sit above everything so key events bubble up to it
//       onKeyEvent: _handleRowNavigation,
//       child: Stack(
//         children: [
//           // Top controls
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: FocusTraversalGroup(
//               child: Row(
//                 children: [
//                   IconButton(
//                     focusNode: _topRowFocusNode,
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () =>
//                         Navigator.of(context).pop(), // pop your own route now
//                   ),
//                   const Spacer(),
//                   if (_isPipAvailable)
//                     IconButton(
//                       icon: const Icon(
//                         Icons.picture_in_picture_alt,
//                         color: Colors.white,
//                       ),
//                       onPressed: () async {
//                         await widget.controller.enterPictureInPicture();
//                       },
//                       tooltip: 'Picture in Picture',
//                     ),
//                   // AirPlay button (only shown if available)
//                   if (_isAirPlayAvailable)
//                     IconButton(
//                       icon: Icon(
//                         _isAirPlayConnected
//                             ? Icons.cast_connected
//                             : Icons.airplay,
//                         color: _isAirPlayConnected ? Colors.blue : Colors.white,
//                       ),
//                       onPressed: () async {
//                         await widget.controller.showAirPlayPicker();
//                       },
//                       tooltip: _isAirPlayConnected
//                           ? 'AirPlay Connected'
//                           : 'AirPlay',
//                     ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Control buttons
//           Center(
//             child: FocusTraversalGroup(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Skip backward
//                   IconButton(
//                     icon: const Icon(Icons.replay_10, color: Colors.white),
//                     onPressed: () {
//                       widget.controller.seekTo(
//                         _currentPosition - const Duration(seconds: 10),
//                       );
//                     },
//                   ),
//
//                   // Center play/pause button
//                   _buildPlayPauseButton(),
//
//                   // Skip forward
//                   IconButton(
//                     icon: const Icon(Icons.forward_10, color: Colors.white),
//                     onPressed: () {
//                       widget.controller.seekTo(
//                         _currentPosition + const Duration(seconds: 10),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Bottom controls
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: FocusTraversalGroup(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Progress bar
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Row(
//                       spacing: 8,
//                       children: [
//                         Text(
//                           _formatDuration(_currentPosition),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                         Expanded(
//                           child: SliderTheme(
//                             data: SliderThemeData(
//                               trackHeight: 4,
//                               thumbShape: const RoundSliderThumbShape(
//                                 enabledThumbRadius: 6,
//                               ),
//                               overlayShape: const RoundSliderOverlayShape(
//                                 overlayRadius: 12,
//                               ),
//                               activeTrackColor: Colors.red,
//                               inactiveTrackColor: Colors.white.withValues(
//                                 alpha: 0.3,
//                               ),
//                               secondaryActiveTrackColor: Colors.white
//                                   .withValues(alpha: 0.5),
//                               thumbColor: Colors.red,
//                               overlayColor: Colors.red.withValues(alpha: 0.3),
//                             ),
//                             child: Slider(
//                               value: _duration.inMilliseconds > 0
//                                   ? _currentPosition.inMilliseconds
//                                         .toDouble()
//                                         .clamp(
//                                           0.0,
//                                           _duration.inMilliseconds.toDouble(),
//                                         )
//                                   : 0.0,
//                               secondaryTrackValue: _duration.inMilliseconds > 0
//                                   ? _bufferedPosition.inMilliseconds
//                                         .toDouble()
//                                         .clamp(
//                                           0.0,
//                                           _duration.inMilliseconds.toDouble(),
//                                         )
//                                   : 0.0,
//                               min: 0,
//                               max: _duration.inMilliseconds > 0
//                                   ? _duration.inMilliseconds.toDouble()
//                                   : 1.0,
//                               onChangeStart: _onSeekStart,
//                               onChanged: _onSeekChange,
//                               onChangeEnd: _onSeekEnd,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           _formatDuration(_duration),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: _showSpeedSelector,
//                           style: TextButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             minimumSize: Size.zero,
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: Text(
//                             '${_currentSpeed}x',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         if (_qualities.isNotEmpty)
//                           TextButton(
//                             onPressed: _showQualitySelector,
//                             style: TextButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                               ),
//                               minimumSize: Size.zero,
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             ),
//                             child: Text(
//                               _currentQuality?.label ?? 'Auto',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         IconButton(
//                           focusNode: _bottomRowFocusNode,
//                           icon: const Icon(
//                             Icons.closed_caption,
//                             color: Colors.white,
//                           ),
//                           onPressed: _showSubtitlePicker,
//                           tooltip: 'Subtitles',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.black.withValues(alpha: 0.7),
//             Colors.transparent,
//             Colors.transparent,
//             Colors.black.withValues(alpha: 0.7),
//           ],
//           stops: const [0.0, 0.3, 0.7, 1.0],
//         ),
//       ),
//       child: SafeArea(child: stackWidget),
//     );
//   }
//
//   Widget _buildPlayPauseButton() {
//     return Container(
//       width: 64,
//       height: 64,
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.5),
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         focusNode: _centerRowFocusNode,
//         icon: Icon(
//           _activityState.isPlaying ? Icons.pause : Icons.play_arrow,
//           color: Colors.white,
//           size: 36,
//         ),
//         onPressed: () {
//           if (_activityState.isPlaying) {
//             widget.controller.pause();
//           } else {
//             widget.controller.play();
//           }
//         },
//       ),
//     );
//   }
//
//   // Widget _buildPlayPauseButton() {
//   //   // Show loading indicator when buffering or loading
//   //   if (_activityState == PlayerActivityState.buffering ||
//   //       _activityState == PlayerActivityState.loading) {
//   //     return Container(
//   //       width: 64,
//   //       height: 64,
//   //       decoration: BoxDecoration(
//   //         color: Colors.black.withValues(alpha: 0.5),
//   //         shape: BoxShape.circle,
//   //       ),
//   //       child: const Center(
//   //         child: SizedBox(
//   //           width: 32,
//   //           height: 32,
//   //           child: CircularProgressIndicator(
//   //             strokeWidth: 3,
//   //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //
//   //   // Show play/pause button for other states
//   //   return Container(
//   //     width: 64,
//   //     height: 64,
//   //     decoration: BoxDecoration(
//   //       color: Colors.black.withValues(alpha: 0.5),
//   //       shape: BoxShape.circle,
//   //     ),
//   //     child: IconButton(
//   //       autofocus: true,
//   //       icon: Icon(
//   //         _activityState.isPlaying ? Icons.pause : Icons.play_arrow,
//   //         color: Colors.white,
//   //         size: 36,
//   //       ),
//   //       onPressed: () {
//   //         if (_activityState.isPlaying) {
//   //           widget.controller.pause();
//   //         } else {
//   //           widget.controller.play();
//   //         }
//   //       },
//   //     ),
//   //   );
//   // }
//
//   /// Shows the quality selector modal
//   void _showQualitySelector() {
//     showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: Colors.black87,
//       useRootNavigator: false,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Select Quality',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const Divider(color: Colors.white24, height: 1),
//               Flexible(
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: _qualities.map((quality) {
//                     final isSelected = _currentQuality?.label == quality.label;
//                     return ListTile(
//                       title: Text(
//                         quality.label,
//                         style: TextStyle(
//                           color: isSelected ? Colors.red : Colors.white,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                       subtitle: quality.bitrate != null
//                           ? Text(
//                               '${quality.width ?? '?'}x${quality.height ?? '?'} - ${(quality.bitrate! / 1000000).toStringAsFixed(2)} Mbps',
//                               style: TextStyle(
//                                 color: isSelected
//                                     ? Colors.red.withValues(alpha: 0.7)
//                                     : Colors.white70,
//                                 fontSize: 12,
//                               ),
//                             )
//                           : null,
//                       trailing: isSelected
//                           ? const Icon(Icons.check, color: Colors.red)
//                           : null,
//                       onTap: () {
//                         widget.controller.setQuality(quality);
//                         Navigator.pop(context);
//                         if (mounted) {
//                           setState(() {
//                             _currentQuality = quality;
//                           });
//                         }
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   /// Shows the speed selector modal
//   void _showSpeedSelector() {
//     showModalBottomSheet<void>(
//       context: context,
//       backgroundColor: Colors.black87,
//       useRootNavigator: false,
//       builder: (context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Playback Speed',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const Divider(color: Colors.white24, height: 1),
//               Flexible(
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: _availableSpeeds.map((speed) {
//                     final isSelected = _currentSpeed == speed;
//                     return ListTile(
//                       title: Text(
//                         '${speed}x',
//                         style: TextStyle(
//                           color: isSelected ? Colors.red : Colors.white,
//                           fontWeight: isSelected
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                       subtitle: Text(
//                         speed == 1.0
//                             ? 'Normal'
//                             : speed < 1.0
//                             ? 'Slower'
//                             : 'Faster',
//                         style: TextStyle(
//                           color: isSelected
//                               ? Colors.red.withValues(alpha: 0.7)
//                               : Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),
//                       trailing: isSelected
//                           ? const Icon(Icons.check, color: Colors.red)
//                           : null,
//                       onTap: () async {
//                         await widget.controller.setSpeed(speed);
//                         if (!context.mounted) return;
//                         Navigator.pop(context);
//                         if (mounted) {
//                           setState(() {
//                             _currentSpeed = speed;
//                           });
//                         }
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   /// Shows the subtitle picker modal
//   void _showSubtitlePicker() {
//     showSubtitlePicker(
//       context: context,
//       controller: widget.controller,
//       fontSize: _subtitleFontSize,
//       onFontSizeChanged: (newSize) {
//         if (mounted) {
//           setState(() {
//             _subtitleFontSize = newSize;
//           });
//         }
//       },
//     );
//   }
// }
