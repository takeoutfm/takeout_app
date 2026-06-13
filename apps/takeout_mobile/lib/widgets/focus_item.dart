import 'package:flutter/material.dart';

class FocusItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const FocusItem({super.key, required this.child, this.onTap});

  @override
  State<FocusItem> createState() => _FocusItemState();
}

class _FocusItemState extends State<FocusItem> {
  bool focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'FocusItem_${widget.child.runtimeType}');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    debugPrint('FocusItem ${_focusNode.debugLabel}: hasFocus=${_focusNode.hasFocus}');
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (value) {
        setState(() {
          focused = value;
        });
      },
      actions: {
        // Handles enter key and remote control select
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
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
