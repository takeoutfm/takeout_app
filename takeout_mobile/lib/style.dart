// Copyright 2023 defsub
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

import 'package:flutter/material.dart';

const iconsDownload = Icons.cloud_download_outlined;
const iconsDownloadDone = Icons.cloud_done_outlined;
const iconsCached = Icons.download_done_outlined;

Widget header(String text) {
  return Container(
    padding: const EdgeInsets.fromLTRB(0, 11, 0, 11),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
    ),
  );
}

Widget heading(String text) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      padding: const EdgeInsets.fromLTRB(11, 22, 0, 11),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
      ),
    ),
  );
}

Widget headingButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text.toUpperCase(),
              textAlign: TextAlign.justify,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

Widget smallHeading(BuildContext context, String text) {
  return textHeading(context, text, Theme.of(context).textTheme.bodySmall);
}

Widget mediumHeading(BuildContext context, String text) {
  return textHeading(context, text, Theme.of(context).textTheme.bodyMedium);
}

Widget largeHeading(BuildContext context, String text) {
  return textHeading(context, text, Theme.of(context).textTheme.bodyLarge);
}

Widget textHeading(BuildContext context, String text, TextStyle? style) {
  return SizedBox(
    width: double.infinity,
    child: Container(
      padding: const EdgeInsets.fromLTRB(17, 11, 0, 11),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: style),
      ),
    ),
  );
}
