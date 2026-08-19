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

/// Wraps [child] in a Theme forced to [brightness], re-tinting textTheme
/// so context.header1 / context.body / etc. resolve correctly underneath.
class _SurfaceTheme extends StatelessWidget {
  final Brightness brightness;
  final Widget child;
  final Color? surfaceColor; // optional: also override background color

  const _SurfaceTheme({
    super.key,
    required this.brightness,
    required this.child,
    this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final isDark = brightness == Brightness.dark;

    final newColorScheme = isDark ? ColorScheme.dark() : ColorScheme.light();
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
