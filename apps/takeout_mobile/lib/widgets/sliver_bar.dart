import 'package:flutter/material.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/text.dart';

class SliverMenuBar extends StatelessWidget {
  final String? title;
  final List<PopupItem> items;
  final bool allowBack;

  const SliverMenuBar({
    super.key,
    this.title,
    required this.items,
    this.allowBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: allowBack
          ? Center(
              child: CircleButton.back(onTap: () => Navigator.pop(context)),
            )
          : null,
      title: OptionalText(title),
      actions: [
        popupMenu(
          context,
          items,
          icon: null,
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: CircleButton.dropDown(),
          ),
        ),
      ],
    );
  }
}

class SliverFavoriteBar extends StatelessWidget {
  final String? title;
  final void Function() onTap;

  const SliverFavoriteBar({super.key, this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: Center(
        child: CircleButton.back(onTap: () => Navigator.pop(context)),
      ),
      title: title != null ? Text(title!) : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: CircleButton.favorite(onTap: onTap),
        ),
      ],
    );
  }
}
