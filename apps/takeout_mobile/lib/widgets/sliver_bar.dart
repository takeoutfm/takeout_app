import 'package:flutter/material.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';

class SliverMenuBar extends StatelessWidget {
  final String? title;
  final List<PopupItem> items;

  const SliverMenuBar({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: CircleButton.back(onTap: () => Navigator.pop(context)),
      title: title != null ? Text(title!) : null,
      actions: [
        popupMenu(context, items, icon: null, child: CircleButton.dropDown()),
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
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: CircleButton.back(onTap: () => Navigator.pop(context)),
      title: title != null ? Text(title!) : null,
      actions: [CircleButton.favorite(onTap: onTap)],
    );
  }
}
