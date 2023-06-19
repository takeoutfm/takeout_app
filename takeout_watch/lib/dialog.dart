// Copyright 2023 defsub
//
// This file is part of Takeout.
//
// Takeout is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

Future<bool?> confirmDialog(BuildContext context,
    {String? title, String? body}) {
  return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            titleTextStyle: Theme.of(context).textTheme.bodyMedium,
            title: title != null ? Center(child: Text(title)) : null,
            contentTextStyle: Theme.of(context).textTheme.bodySmall,
            content: body != null ? Text(body, textAlign: TextAlign.center) : null,
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop<bool>(context, false),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                onPressed: () => Navigator.pop<bool>(context, true),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ));
}
