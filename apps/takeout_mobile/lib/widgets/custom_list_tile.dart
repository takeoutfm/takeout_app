import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  const CustomListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.focusNode,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.tileColor,
    this.selectedColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minLeadingWidth = 40,
    this.gap = 16,
  });

  /// Widget displayed at the start of the tile (e.g. image, icon, avatar).
  /// Unlike [ListTile], this is unconstrained in height.
  final Widget? leading;

  /// Primary content of the tile. Typically a [Text] widget.
  final Widget title;

  /// Additional content below the title. Typically a [Text] widget.
  final Widget? subtitle;

  /// Widget displayed at the end of the tile (e.g. icon, switch, text).
  final Widget? trailing;

  /// Focus node for keyboard/accessibility navigation.
  final FocusNode? focusNode;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  /// Whether this tile is in a selected state.
  final bool selected;

  /// Background color of the tile. Overridden by [selectedColor] when [selected] is true.
  final Color? tileColor;

  /// Background color when [selected] is true.
  /// Defaults to the theme's primary color with low opacity.
  final Color? selectedColor;

  /// Padding around the tile contents.
  final EdgeInsetsGeometry contentPadding;

  /// Minimum width reserved for the leading widget.
  final double minLeadingWidth;

  /// Horizontal gap between leading, content, and trailing widgets.
  final double gap;

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    // Only dispose if we created the node internally
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  Color _resolveBackgroundColor(BuildContext context) {
    if (widget.selected) {
      return widget.selectedColor ??
          Theme.of(context).colorScheme.primary.withOpacity(0.12);
    }
    return widget.tileColor ?? Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final effectiveTitleStyle = (widget.selected
            ? textTheme.bodyLarge?.copyWith(color: colorScheme.primary)
            : textTheme.bodyLarge) ??
        const TextStyle();

    final effectiveSubtitleStyle = (widget.selected
            ? textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary.withOpacity(0.7),
              )
            : textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              )) ??
        const TextStyle();

    return Focus(
      focusNode: _focusNode,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        focusColor: colorScheme.primary.withOpacity(0.08),
        highlightColor: colorScheme.primary.withOpacity(0.06),
        splashColor: colorScheme.primary.withOpacity(0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _isFocused
              ? colorScheme.primary.withOpacity(0.08)
              : _resolveBackgroundColor(context),
          child: Padding(
            padding: widget.contentPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Leading ──────────────────────────────────────────
                if (widget.leading != null) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: widget.minLeadingWidth,
                    ),
                    child: widget.leading,
                  ),
                  SizedBox(width: widget.gap),
                ],

                // ── Title + Subtitle ─────────────────────────────────
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: effectiveTitleStyle,
                        child: widget.title,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: effectiveSubtitleStyle,
                          child: widget.subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Trailing ─────────────────────────────────────────
                if (widget.trailing != null) ...[
                  SizedBox(width: widget.gap),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Example usage
// ─────────────────────────────────────────────────────────────────────────────

class CustomListTileExample extends StatefulWidget {
  const CustomListTileExample({super.key});

  @override
  State<CustomListTileExample> createState() => _CustomListTileExampleState();
}

class _CustomListTileExampleState extends State<CustomListTileExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomListTile Demo')),
      body: ListView(
        children: [
          // Tall leading image — the whole reason we built this
          CustomListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://picsum.photos/seed/flutter/80/100',
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            title: const Text('Tall leading image'),
            subtitle: const Text('Height not constrained — try that with ListTile!'),
            trailing: const Icon(Icons.chevron_right),
            selected: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),

          const Divider(height: 1),

          // Standard icon leading
          CustomListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Jane Doe'),
            subtitle: const Text('jane@example.com'),
            trailing: const Icon(Icons.chevron_right),
            selected: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),

          const Divider(height: 1),

          // Custom tileColor + no subtitle
          CustomListTile(
            leading: const Icon(Icons.star, color: Colors.amber, size: 32),
            title: const Text('Favourited item'),
            tileColor: Colors.amber.withOpacity(0.08),
            trailing: const Text('4.9 ★'),
            selected: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),

          const Divider(height: 1),

          // No leading
          CustomListTile(
            title: const Text('No leading widget'),
            subtitle: const Text('Leading is fully optional'),
            trailing: const Switch(value: true, onChanged: null),
            selected: _selectedIndex == 3,
            onTap: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
    );
  }
}
