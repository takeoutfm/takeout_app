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

import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? edgeInsetsGeometry;
  final EdgeInsetsGeometry? padding;

  const CircleButton(
      {required this.icon,
      this.onPressed,
      this.edgeInsetsGeometry,
      this.padding,
      super.key});

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.black54,
        padding: edgeInsetsGeometry ?? const EdgeInsets.all(20),
      ),
      onPressed: onPressed,
      child: icon,
    );
    return padding != null
        ? Container(padding: padding, child: button)
        : button;
  }
}
