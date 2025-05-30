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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takeout_lib/api/client.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/snackbar.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                child: Text(context.strings.connectLabel),
                onPressed: () {
                  Navigator.push(context,
                      CupertinoPageRoute<void>(builder: (_) => CodePage()));
                }),
          ],
        ),
      ),
    );
  }
}

class CodePage extends ClientPage<AccessCode> {
  CodePage({super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.code();
  }

  void check(BuildContext context, AccessCode state) {
    context.clientRepository.checkCode(state).then((success) {
      if (context.mounted) {
        if (success) {
          Navigator.pop(context);
        } else {
          snackBar(context, context.strings.codeNotLinked);
        }
      }
    }).onError((error, stackTrace) {
      if (context.mounted) {
        if (error is InvalidCodeError) {
          snackBar(context, context.strings.codeInvalid);
          reload(context);
        }
      }
    });
  }

  @override
  Widget page(BuildContext context, AccessCode state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(context.settings.state.settings.host),
            const SizedBox(height: 16),
            Text(state.code),
            TextButton(
                child: Text(context.strings.nextLabel),
                onPressed: () => check(context, state)),
          ],
        ),
      ),
    );
  }
}
