import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double padding;

  static const double _defaultPadding = 12;
  static const double _appBarPadding = 6;

  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.padding = _defaultPadding,
  });

  const CircleButton.back({
    Key? key,
    required VoidCallback? onTap,
    double? padding,
  }) : this(
         key: key,
         icon: Icons.arrow_back,
         onTap: onTap,
         padding: padding ?? _appBarPadding,
       );

  const CircleButton.favorite({
    Key? key,
    required VoidCallback? onTap,
    double? padding,
  }) : this(
         key: key,
         icon: Icons.favorite_border,
         onTap: onTap,
         padding: padding ?? _appBarPadding,
       );

  const CircleButton.menu({Key? key, double? padding})
    : this(
        key: key,
        icon: Icons.menu,
        onTap: null,
        padding: padding ?? _defaultPadding,
      );

  const CircleButton.moreHorizontal({Key? key, double? padding})
    : this(
        key: key,
        icon: Icons.more_horiz,
        onTap: null,
        padding: padding ?? _defaultPadding,
      );

  const CircleButton.moreVertical({Key? key, double? padding})
    : this(
        key: key,
        icon: Icons.more_vert,
        onTap: null,
        padding: padding ?? _defaultPadding,
      );

  const CircleButton.dropDown({Key? key, double? padding})
    : this(
        key: key,
        icon: Icons.keyboard_arrow_down,
        onTap: null,
        padding: padding ?? _defaultPadding,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
