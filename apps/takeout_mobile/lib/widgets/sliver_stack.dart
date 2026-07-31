import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:takeout_lib/art/cover.dart';

class SliverStack extends StatelessWidget {
  final List<Widget> slivers;
  final String? backdrop;
  final bool blur;
  final Widget? footer;

  const SliverStack({
    super.key,
    required this.slivers,
    this.backdrop,
    this.blur = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop
        if (backdrop != null) backdropImage(context, backdrop!),

        // Dark overlay
        Container(color: Colors.black.withValues(alpha: 0.65)),

        // Blur effect
        if (blur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), //12
            child: Container(
              color: Colors.black.withValues(alpha: 0.2), // 0.2
            ),
          ),

        SafeArea(
          child: Column(
            children: [
              Expanded(child: CustomScrollView(slivers: slivers)),
              ?footer,
            ],
          ),
        ),
      ],
    );
  }
}
