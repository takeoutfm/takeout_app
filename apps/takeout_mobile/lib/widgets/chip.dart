import 'package:flutter/material.dart';
import 'package:takeout_mobile/app/text_style.dart';

class MyChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextOverflow? overflow;

  const MyChip({
    super.key,
    required this.label,
    required this.onPressed,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            label,
            style: AppTextStyle.chip.copyWith(overflow: overflow),
          ),
        ),
      ),
    );
  }
}
