import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const CircleButton({super.key, required this.icon, required this.onTap});

  const CircleButton.back({super.key, required this.onTap})
    : icon = Icons.arrow_back;

  const CircleButton.favorite({super.key, required this.onTap})
    : icon = Icons.favorite_border;

  const CircleButton.menu({super.key}) : icon = Icons.menu, onTap = null;

  const CircleButton.moreHorizontal({super.key})
    : icon = Icons.more_horiz,
      onTap = null;

  const CircleButton.moreVertical({super.key})
    : icon = Icons.more_vert,
      onTap = null;

  const CircleButton.dropDown({super.key})
      : icon = Icons.keyboard_arrow_down,
        onTap = null;

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
          padding: const EdgeInsets.all(8),
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
