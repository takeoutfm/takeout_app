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
        if (backdrop != null)
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
