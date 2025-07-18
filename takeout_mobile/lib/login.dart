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
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';

class LoginWidget extends ClientPage<bool> {
  final TextEditingController _hostText = TextEditingController();
  final TextEditingController _userText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  final TextEditingController _passcodeText = TextEditingController();

  LoginWidget({super.key}) : super(value: false);

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) async {
    final host = _hostText.text.trim();
    if (host.isNotEmpty) {
      context.settings.host = host;
    }

    // TODO assume host is emitted into settings repo for login below

    final user = _userText.text.trim();
    final password = _passwordText.text.trim();
    final passcode = _passcodeText.text.trim();
    if (user.isNotEmpty && password.isNotEmpty) {
      await context.client.login(user, password,
          passcode: passcode.isNotEmpty ? passcode : null);
    }
  }

  @override
  Widget page(BuildContext context, bool state) {
    if (state) {
      context.app.authenticated();
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
                      context.strings.hostLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 30),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _hostText,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.strings.hostLabel,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      context.strings.loginLabel,
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
                    height: 70,
                    padding: const EdgeInsets.all(10),
                    child: OutlinedButton(
                      child: Text(context.strings.loginLabel),
                      onPressed: () {
                        reloadPage(context);
                      },
                    )),
              ],
            )));
  }
}
