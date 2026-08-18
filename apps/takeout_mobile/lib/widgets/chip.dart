import 'package:flutter/material.dart';
import 'package:takeout_mobile/app/context.dart';

class MyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final TextOverflow? overflow;
  final IconData? icon;
  final bool autofocus;

  const MyChip({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.overflow,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        autofocus: autofocus,
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.labelLarge?.copyWith(overflow: overflow),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
