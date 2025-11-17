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
import 'package:takeout_mobile/app/context.dart';

Future<void> showAlertDialog(
  BuildContext context,
  String message, {
  void Function()? onConfirmed,
}) => showDialog<void>(
  context: context,
  builder: (BuildContext ctx) {
    return AlertDialog(
      title: Text(MaterialLocalizations.of(context).alertDialogLabel),
      content: Text(message),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () {
            Navigator.pop(ctx);
            onConfirmed?.call();
          },
        ),
      ],
    );
  },
);

Future<String?> textDialog(
  BuildContext context,
  String label, {
  String? hint,
}) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext ctx) {
      final text = TextField(
        onSubmitted: (value) {
          Navigator.pop(ctx, value);
        },
        autofocus: true,
        decoration: InputDecoration(labelText: label, hintText: hint),
      );
      return AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(children: <Widget>[Expanded(child: text)]),
        actions: <Widget>[
          TextButton(
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
        ],
      );
    },
  );
}

void confirmDeleteDialog(
  BuildContext context,
  String message,
  void Function() onConfirm,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(context.strings.confirmDelete),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    },
  );
}
