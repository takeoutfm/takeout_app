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

class SurfaceTheme extends StatelessWidget {
  final Brightness brightness;
  final Widget child;
  final Color? surfaceColor;

  const SurfaceTheme({
    super.key,
    required this.brightness,
    required this.child,
    this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final isDark = brightness == Brightness.dark;

    final newColorScheme = baseTheme.colorScheme.copyWith(
      brightness: brightness,
      surface: surfaceColor ?? (isDark ? Colors.grey[900]! : Colors.white),
      onSurface: isDark ? Colors.white : Colors.black,
      // keep primary, secondary, error, etc. from baseTheme — untouched
    );

    final textColor = newColorScheme.onSurface;

    return Theme(
      data: baseTheme.copyWith(
        brightness: brightness,
        colorScheme: newColorScheme,
        textTheme: baseTheme.textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
      ),
      child: Builder(
        builder: (context) => surfaceColor != null
            ? ColoredBox(color: surfaceColor!, child: child)
            : child,
      ),
    );
  }
}
