import 'package:flutter/material.dart';

/// A progress bar that supports both touch (tap/drag anywhere on the bar to
/// seek) and D-pad (the parent overlay drives fixed-increment seeking via
/// key events on [focusNode], see CustomVideoOverlay._handleRowNavigation).
///
/// This intentionally does NOT use Flutter's built-in [Slider]. Slider
/// bundles its own internal keyboard handling (arrow-key stepping) whenever
/// it's touch-interactive (onChanged != null), and there's no supported way
/// to keep touch support while disabling just the keyboard piece — it's an
/// all-or-nothing switch. A custom widget avoids that conflict entirely:
/// touch is handled here via GestureDetector, D-pad is handled entirely by
/// the parent's key event logic, and neither interferes with the other.
class VideoProgressBar extends StatelessWidget {
  final FocusNode focusNode;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  /// Called continuously while dragging, for live position feedback.
  final ValueChanged<Duration> onSeekPreview;

  /// Called once the user releases a drag or taps a position — this is
  /// where you should call the actual controller.seekTo().
  final ValueChanged<Duration> onSeekCommit;

  /// Called the moment a touch/drag begins. Use this to pause any
  /// auto-hide timer on the parent overlay, so controls can't disappear
  /// mid-drag.
  final VoidCallback? onDragStart;

  /// Called once the touch/drag ends (mirrors onSeekCommit timing). Use
  /// this to resume the auto-hide timer.
  final VoidCallback? onDragEnd;

  const VideoProgressBar({
    required this.focusNode,
    required this.position,
    required this.bufferedPosition,
    required this.duration,
    required this.onSeekPreview,
    required this.onSeekCommit,
    this.onDragStart,
    this.onDragEnd,
    super.key,
  });

  double _fractionFor(Duration d) {
    if (duration.inMilliseconds <= 0) return 0.0;
    return (d.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  Duration _durationFor(double fraction, double width) {
    if (width <= 0 || duration.inMilliseconds <= 0) return Duration.zero;
    final clamped = fraction.clamp(0.0, 1.0);
    return Duration(
      milliseconds: (clamped * duration.inMilliseconds).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              void handleLocalPosition(double dx) {
                final fraction = (dx / width).clamp(0.0, 1.0);
                onSeekPreview(_durationFor(fraction, width));
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  onDragStart?.call();
                  handleLocalPosition(details.localPosition.dx);
                },
                onTapUp: (details) {
                  final fraction =
                  (details.localPosition.dx / width).clamp(0.0, 1.0);
                  onSeekCommit(_durationFor(fraction, width));
                  onDragEnd?.call();
                },
                onHorizontalDragStart: (details) {
                  onDragStart?.call();
                  handleLocalPosition(details.localPosition.dx);
                },
                onHorizontalDragUpdate: (details) {
                  handleLocalPosition(details.localPosition.dx);
                },
                onHorizontalDragEnd: (_) {
                  onSeekCommit(position);
                  onDragEnd?.call();
                },
                child: SizedBox(
                  height: 24, // generous hit area, taller than the visible track
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // background track
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // buffered track
                        FractionallySizedBox(
                          widthFactor: _fractionFor(bufferedPosition),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // played track
                        FractionallySizedBox(
                          widthFactor: _fractionFor(position),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // thumb
                        Positioned(
                          left: (_fractionFor(position) * width) - 8,
                          top: -6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              border: hasFocus
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// /// A progress bar that supports both touch (tap/drag anywhere on the bar to
// /// seek) and D-pad (the parent overlay drives fixed-increment seeking via
// /// key events on [focusNode], see CustomVideoOverlay._handleRowNavigation).
// ///
// /// This intentionally does NOT use Flutter's built-in [Slider]. Slider
// /// bundles its own internal keyboard handling (arrow-key stepping) whenever
// /// it's touch-interactive (onChanged != null), and there's no supported way
// /// to keep touch support while disabling just the keyboard piece — it's an
// /// all-or-nothing switch. A custom widget avoids that conflict entirely:
// /// touch is handled here via GestureDetector, D-pad is handled entirely by
// /// the parent's key event logic, and neither interferes with the other.
// class VideoProgressBar extends StatelessWidget {
//   final FocusNode focusNode;
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;
//
//   /// Called continuously while dragging, for live position feedback.
//   final ValueChanged<Duration> onSeekPreview;
//
//   /// Called once the user releases a drag or taps a position — this is
//   /// where you should call the actual controller.seekTo().
//   final ValueChanged<Duration> onSeekCommit;
//
//   const VideoProgressBar({
//     required this.focusNode,
//     required this.position,
//     required this.bufferedPosition,
//     required this.duration,
//     required this.onSeekPreview,
//     required this.onSeekCommit,
//     super.key,
//   });
//
//   double _fractionFor(Duration d) {
//     if (duration.inMilliseconds <= 0) return 0.0;
//     return (d.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
//   }
//
//   Duration _durationFor(double fraction, double width) {
//     if (width <= 0 || duration.inMilliseconds <= 0) return Duration.zero;
//     final clamped = fraction.clamp(0.0, 1.0);
//     return Duration(
//       milliseconds: (clamped * duration.inMilliseconds).round(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//       focusNode: focusNode,
//       child: Builder(
//         builder: (context) {
//           final hasFocus = Focus.of(context).hasFocus;
//
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               final width = constraints.maxWidth;
//
//               void handleLocalPosition(double dx) {
//                 final fraction = (dx / width).clamp(0.0, 1.0);
//                 onSeekPreview(_durationFor(fraction, width));
//               }
//
//               return GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTapDown: (details) {
//                   handleLocalPosition(details.localPosition.dx);
//                 },
//                 onTapUp: (details) {
//                   final fraction =
//                   (details.localPosition.dx / width).clamp(0.0, 1.0);
//                   onSeekCommit(_durationFor(fraction, width));
//                 },
//                 onHorizontalDragStart: (details) {
//                   handleLocalPosition(details.localPosition.dx);
//                 },
//                 onHorizontalDragUpdate: (details) {
//                   handleLocalPosition(details.localPosition.dx);
//                 },
//                 onHorizontalDragEnd: (_) {
//                   onSeekCommit(position);
//                 },
//                 child: SizedBox(
//                   height: 24, // generous hit area, taller than the visible track
//                   child: Center(
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         // background track
//                         Container(
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.3),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         // buffered track
//                         FractionallySizedBox(
//                           widthFactor: _fractionFor(bufferedPosition),
//                           child: Container(
//                             height: 4,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withValues(alpha: 0.5),
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                         ),
//                         // played track
//                         FractionallySizedBox(
//                           widthFactor: _fractionFor(position),
//                           child: Container(
//                             height: 4,
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                         ),
//                         // thumb
//                         Positioned(
//                           left: (_fractionFor(position) * width) - 8,
//                           top: -6,
//                           child: Container(
//                             width: 16,
//                             height: 16,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.red,
//                               border: hasFocus
//                                   ? Border.all(color: Colors.white, width: 2)
//                                   : null,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }