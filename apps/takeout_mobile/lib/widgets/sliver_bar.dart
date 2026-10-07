// Copyright 2026 defsub
//
// This file is part of TakeoutFM.
//
// TakeoutFM is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// TakeoutFM is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with TakeoutFM.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:takeout_mobile/widgets/chip.dart';
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
  final bool isFavorite;

  const SliverFavoriteBar({
    super.key,
    this.title,
    this.isFavorite = false,
    required this.onTap,
  });

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
          child: CircleButton.favorite(isFavorite: isFavorite, onTap: onTap),
        ),
      ],
    );
  }
}

class SliverFavoriteMenuBar extends StatelessWidget {
  final String? title;
  final List<PopupItem> items;
  final bool allowBack;
  final bool isFavorite;
  final void Function() onTap;

  const SliverFavoriteMenuBar({
    super.key,
    this.title,
    required this.items,
    required this.onTap,
    this.allowBack = true,
    this.isFavorite = false,
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
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6),
          child: CircleButton.favorite(isFavorite: isFavorite, onTap: onTap),
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

abstract class SliverActionBar extends StatelessWidget {
  const SliverActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: surface.withValues(
              alpha: 0.1,
            ), // matches page bg, blends in both themes
          ),
        ),
      ),
      title: Wrap(spacing: 20, children: actions(context)),
    );
  }

  List<MyChip> actions(BuildContext context);
}