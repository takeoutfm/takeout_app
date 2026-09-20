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
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/app/context.dart';

class AvatarButton extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const AvatarButton({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          DpadFocusable(
            onSelect: onTap,
            child: InkWell(onTap: onTap, child: avatar(context, imageUrl)),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.labelMedium?.copyWith(color: Colors.white),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.labelSmall?.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
    // return InkWell(
    //   onTap: onTap,
    //   child: Container(
    //     width: 96,
    //     margin: const EdgeInsets.only(right: 16),
    //     child: Column(
    //       children: [
    //         avatar(context, imageUrl),
    //         const SizedBox(height: 8),
    //         Text(
    //           name,
    //           textAlign: TextAlign.center,
    //           maxLines: 2,
    //           overflow: TextOverflow.ellipsis,
    //           style: context.labelMedium?.copyWith(color: Colors.white),
    //         ),
    //         if (subtitle != null)
    //           Text(
    //             subtitle!,
    //             textAlign: TextAlign.center,
    //             maxLines: 2,
    //             overflow: TextOverflow.ellipsis,
    //             style: context.labelSmall?.copyWith(color: Colors.white70),
    //           ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
