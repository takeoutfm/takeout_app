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
import 'package:flutter/services.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/empty.dart';

class LinkWidget extends ClientPage<bool> {
  final TextEditingController _userText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _passcodeText = TextEditingController();
  final TextEditingController _codeText = TextEditingController();

  LinkWidget({super.key}) : super(value: false);

  @override
  void load(BuildContext context, {Duration? ttl}) {
    final user = _userText.text.trim();
    final password = _passwordText.text.trim();
    final passcode = _passcodeText.text.trim();
    final code = _codeText.text.trim();
    if (user.isNotEmpty && password.isNotEmpty && code.isNotEmpty) {
      context.client.link(
        code: code,
        user: user,
        password: password,
        passcode: passcode,
      );
    }
  }

  @override
  Widget page(BuildContext context, bool state) {
    if (state) {
      return const EmptyWidget();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(context.strings.takeoutTitle),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      context.strings.linkTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 30),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _userText,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.strings.userLabel,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    obscureText: true,
                    controller: _passwordText,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.strings.passwordLabel,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _passcodeText,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.strings.passcodeLabel,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _codeText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.strings.codeLabel,
                    ),
                  ),
                ),
                Container(
                    height: 70,
                    padding: const EdgeInsets.all(10),
                    child: OutlinedButton(
                      child: Text(context.strings.linkLabel),
                      onPressed: () {
                        reloadPage(context);
                      },
                    )),
              ],
            )));
  }
}
