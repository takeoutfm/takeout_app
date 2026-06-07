import 'package:flutter/material.dart';
import 'package:takeout_mobile/widgets/custom_list_tile.dart';

class FocusedListTile extends StatefulWidget {
  final bool selected;
  final bool isThreeLine;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final Widget? title;
  final TextStyle? style;
  final Color? tileColor;

  const FocusedListTile({
    super.key,
    this.selected = false,
    this.isThreeLine = false,
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.subtitle,
    this.title,
    this.style,
    this.tileColor,
  });

  @override
  State<FocusedListTile> createState() => _FocusedListTileState();
}

class _FocusedListTileState extends State<FocusedListTile> {
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),

      decoration: BoxDecoration(
        color: focused
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: focused ? Colors.white : Colors.transparent,
          width: 3,
        ),

        boxShadow: focused
            ? [BoxShadow(blurRadius: 16, color: Colors.white24)]
            : [],
      ),

      child: SizedBox(
        height: 100,
        child: CustomListTile(
          focusNode: focusNode,
          title: widget.title!,
          subtitle: widget.subtitle,
          leading: widget.leading,
          trailing: widget.trailing,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          selected: widget.selected,
          tileColor: widget.tileColor,
        ),
      ),
    );
  }
}
