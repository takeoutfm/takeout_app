import 'dart:ui';

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
      flexibleSpace: title != null
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ), // slight tint helps too
                ),
              ),
            )
          : null,
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
      flexibleSpace: title != null
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ), // slight tint helps too
                ),
              ),
            )
          : null,
      leading: Center(
        child: CircleButton.back(onTap: () => Navigator.pop(context)),
      ),
      title: OptionalText(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: CircleButton.favorite(onTap: onTap),
        ),
      ],
    );
  }
}

class SliverTitleBar extends StatelessWidget {
  final String? title;

  const SliverTitleBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.1), // slight tint helps too
          ),
        ),
      ),
      leading: Center(
        child: CircleButton.back(onTap: () => Navigator.pop(context)),
      ),
      title: OptionalText(title),
    );
  }
}
