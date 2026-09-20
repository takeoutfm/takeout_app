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

import 'package:flutter/material.dart';

class SliverBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  static const edgePadding = 20.0;

  const SliverBox({
    super.key,
    required this.child,
    this.decoration,
    this.padding = const EdgeInsetsGeometry.all(edgePadding),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(padding: padding, decoration: decoration, child: child),
    );
  }
}
