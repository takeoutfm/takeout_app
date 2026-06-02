import 'package:flutter/material.dart';

class FocusItem extends StatefulWidget {
  final Widget child;

  const FocusItem({super.key, required this.child});

  @override
  State<FocusItem> createState() => _FocusItemState();
}

class _FocusItemState extends State<FocusItem> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (value) {
        setState(() {
          focused = value;
        });
      },

      child: AnimatedScale(
        scale: focused ? 1.06 : 1,
        duration: const Duration(milliseconds: 120),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focused ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),

          child: widget.child,
        ),
      ),
    );
  }
}
