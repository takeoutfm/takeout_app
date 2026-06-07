import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class NowPlayingIndicator extends StatefulWidget {
  const NowPlayingIndicator({
    super.key,
    this.size = 24,
    this.barWidth = 3,
    this.barSpacing = 2,
    this.color,
  });

  final double size;
  final double barWidth;
  final double barSpacing;
  final Color? color;

  @override
  State<NowPlayingIndicator> createState() => _NowPlayingIndicatorState();
}

class _NowPlayingIndicatorState extends State<NowPlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<double> _phaseOffsets = [0.0, 0.33, 0.66];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barHeight(double t, double phase) {
    // Wrap into [0,1)
    final x = (t + phase) % 1.0;

    // Triangle wave:
    // 0 -> 1 -> 0
    final triangle = x < 0.5 ? x * 2 : (1 - x) * 2;

    // Scale to 25% .. 100% height.
    return 0.25 + triangle * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.barSpacing / 2,
                ),
                child: Container(
                  width: widget.barWidth,
                  height:
                      widget.size *
                      _barHeight(_controller.value, _phaseOffsets[i]),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(widget.barWidth),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// class NowPlayingIndicator extends StatefulWidget {
//   const NowPlayingIndicator({
//     super.key,
//     this.size = 24,
//     this.barWidth = 3,
//     this.barSpacing = 2,
//     this.color,
//   });
//
//   final double size;
//   final double barWidth;
//   final double barSpacing;
//   final Color? color;
//
//   @override
//   State<NowPlayingIndicator> createState() => _NowPlayingIndicatorState();
// }
//
// class _NowPlayingIndicatorState extends State<NowPlayingIndicator>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   final _random = Random();
//
//   late List<double> _heights;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _heights = [0.3, 0.7, 0.5];
//
//     _controller =
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 250),
//         )..addListener(() {
//           if (_controller.isCompleted) {
//             setState(() {
//               _heights = List.generate(
//                 3,
//                 (_) => 0.25 + _random.nextDouble() * 0.75,
//               );
//             });
//             _controller.forward(from: 0);
//           }
//         });
//
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = widget.color ?? Theme.of(context).colorScheme.primary;
//
//     return SizedBox(
//       width: widget.size,
//       height: widget.size,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: List.generate(
//           3,
//           (i) => Padding(
//             padding: EdgeInsets.symmetric(horizontal: widget.barSpacing / 2),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               width: widget.barWidth,
//               height: widget.size * _heights[i],
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(widget.barWidth),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
