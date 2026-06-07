import 'dart:async';
import 'package:flutter/material.dart';

class SmoothMediaProgress extends StatefulWidget {
  const SmoothMediaProgress({
    super.key,
    required this.positionStream,
    required this.duration,
    this.onSeek,
    this.color,
    this.backgroundColor,
    this.minHeight = 4.0,
    this.thumbRadius = 8.0,
    this.thumbColor,
    this.seekSnapThreshold = 0.05,
    this.targetFps = 60,
  });

  /// Stream of current playback position, emitted ~once per second.
  final Stream<Duration> positionStream;

  /// Total duration of the media.
  final Duration duration;

  /// Called with the seeked [Duration] when the user drags or taps.
  /// If null, seeking is disabled and the widget behaves as a plain indicator.
  final ValueChanged<Duration>? onSeek;

  /// Progress bar fill color. Defaults to theme primary.
  final Color? color;

  /// Progress bar track color. Defaults to theme primary with low opacity.
  final Color? backgroundColor;

  /// Height of the progress bar track.
  final double minHeight;

  /// Radius of the seek thumb. Only shown when [onSeek] is provided.
  final double thumbRadius;

  /// Color of the seek thumb. Defaults to [color] or theme primary.
  final Color? thumbColor;

  /// Fractional position delta above which a stream update snaps instead
  /// of animating. Defaults to 0.05 (~3 s on a 60 s track).
  final double seekSnapThreshold;

  /// Maximum repaint rate. Reduce on platforms with high CPU usage.
  /// 60 = smooth on Android/iOS. 20-30 = better on Linux.
  final int targetFps;

  @override
  State<SmoothMediaProgress> createState() => _SmoothMediaProgressState();
}

class _SmoothMediaProgressState extends State<SmoothMediaProgress>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  // Drives repaints at targetFps rather than letting the controller
  // trigger a repaint on every 60fps tick.
  Timer? _frameThrottle;

  // Drag state — ValueNotifiers avoid setState during drag.
  final ValueNotifier<double> _dragNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _draggingNotifier = ValueNotifier(false);

  StreamSubscription<Duration>? _sub;

  bool get _seekable => widget.onSeek != null;

  Duration get _throttleDuration =>
      Duration(milliseconds: (1000 / widget.targetFps).round());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(_onAnimationTick);
    _subscribeToStream();
  }

  @override
  void didUpdateWidget(SmoothMediaProgress old) {
    super.didUpdateWidget(old);
    if (old.positionStream != widget.positionStream) {
      _sub?.cancel();
      _subscribeToStream();
    }
  }

  void _onAnimationTick() {
    if (_draggingNotifier.value) return;
    // Only schedule one repaint per throttle window.
    _frameThrottle ??= Timer(_throttleDuration, () {
      if (mounted) setState(() {});
      _frameThrottle = null;
    });
  }

  void _subscribeToStream() {
    _sub = widget.positionStream.listen((position) {
      if (_draggingNotifier.value) return;
      _animateTo(_fractional(position));
    });
  }

  double _fractional(Duration position) {
    final totalMs = widget.duration.inMilliseconds;
    if (totalMs == 0) return 0.0;
    return (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
  }

  void _animateTo(double target) {
    final delta = (target - _controller.value).abs();
    if (delta > widget.seekSnapThreshold) {
      _controller.value = target;
    } else {
      _controller.animateTo(
        target,
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );
    }
  }

  // ── Drag handlers ──────────────────────────────────────────────────────────

  void _onDragStart(double fraction) {
    _controller.stop();
    _draggingNotifier.value = true;
    _dragNotifier.value = fraction.clamp(0.0, 1.0);
  }

  void _onDragUpdate(double fraction) {
    _dragNotifier.value = fraction.clamp(0.0, 1.0);
    if (mounted) setState(() {});
  }

  void _onDragEnd() {
    final seekMs = (_dragNotifier.value * widget.duration.inMilliseconds).round();
    widget.onSeek!(Duration(milliseconds: seekMs));
    _controller.value = _dragNotifier.value;
    _draggingNotifier.value = false;
  }

  double _fractionFromLocal(double dx, double width) =>
      (dx / width).clamp(0.0, 1.0);

  @override
  void dispose() {
    _frameThrottle?.cancel();
    _controller.removeListener(_onAnimationTick);
    _controller.dispose();
    _dragNotifier.dispose();
    _draggingNotifier.dispose();
    _sub?.cancel();
    super.dispose();
  }

  // ── Build helpers ──────────────────────────────────────────────────────────

  Widget _buildTrack({
    required Color color,
    required Color backgroundColor,
    required double value,
    required double width,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.minHeight / 2),
      child: SizedBox(
        height: widget.minHeight,
        width: width,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: backgroundColor)),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: width * value,
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(Color color) => Container(
        width: widget.thumbRadius * 2,
        height: widget.thumbRadius * 2,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = widget.color ?? colorScheme.primary;
    final effectiveBg =
        widget.backgroundColor ?? colorScheme.primary.withOpacity(0.2);
    final effectiveThumb = widget.thumbColor ?? effectiveColor;

    final displayValue = _draggingNotifier.value
        ? _dragNotifier.value
        : _controller.value;

    // ── Plain indicator ────────────────────────────────────────────────────
    if (!_seekable) {
      return LayoutBuilder(
        builder: (context, constraints) => _buildTrack(
          color: effectiveColor,
          backgroundColor: effectiveBg,
          value: displayValue,
          width: constraints.maxWidth,
        ),
      );
    }

    // ── Seekable ───────────────────────────────────────────────────────────
    final hitHeight = (widget.thumbRadius * 2).clamp(widget.minHeight, 48.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) =>
              _onDragStart(_fractionFromLocal(d.localPosition.dx, width)),
          onHorizontalDragUpdate: (d) =>
              _onDragUpdate(_fractionFromLocal(d.localPosition.dx, width)),
          onHorizontalDragEnd: (_) => _onDragEnd(),
          onTapDown: (d) =>
              _onDragStart(_fractionFromLocal(d.localPosition.dx, width)),
          onTapUp: (_) => _onDragEnd(),
          child: SizedBox(
            height: hitHeight,
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildTrack(
                      color: effectiveColor,
                      backgroundColor: effectiveBg,
                      value: displayValue,
                      width: width,
                    ),
                  ),
                ),
                Positioned(
                  left: (displayValue * width) - widget.thumbRadius,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _draggingNotifier,
                    builder: (_, dragging, child) => Transform.scale(
                      scale: dragging ? 1.3 : 1.0,
                      child: child,
                    ),
                    child: _buildThumb(effectiveThumb),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
