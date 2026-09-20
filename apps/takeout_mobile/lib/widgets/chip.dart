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

import 'package:dpad/dpad.dart';
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
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return DpadFocusable(
      onSelect: onTap,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          autofocus: autofocus,
          splashColor: onSurface.withValues(alpha: 0.2),
          highlightColor: onSurface.withValues(alpha: 0.1),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: onSurface.withValues(alpha: 0.24)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: onSurface),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: context.labelLarge?.copyWith(
                    overflow: overflow,
                    color: onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

