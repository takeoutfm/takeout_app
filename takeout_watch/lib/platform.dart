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

import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';

// These values are from Android.
const flagActivityNewTask = 268435456;
const flagActivityClearTask = 67108864;

void platformSoundSettings() {
  if (Platform.isAndroid) {
    const intent = AndroidIntent(
      action: 'android.settings.SOUND_SETTINGS',
      flags: [
        flagActivityNewTask,
        flagActivityClearTask,
      ],
    );
    intent.launch();
  }
}

void platformBluetoothSettings() {
  if (Platform.isAndroid) {
    const intent = AndroidIntent(
      // this requires bluetooth permission
      action: 'android.settings.BLUETOOTH_SETTINGS',
      flags: [
        flagActivityNewTask,
        flagActivityClearTask,
      ],
      arguments: {
        'EXTRA_CONNECTION_ONLY': true,
        'EXTRA_CLOSE_ON_CONNECT': true,
        'android.bluetooth.devicepicker.extra.FILTER_TYPE': 1,
      },
    );
    intent.launch();
  }
}

Future<Map<String, dynamic>> deviceInfo() async {
  final deviceInfo = await DeviceInfoPlugin().deviceInfo;
  return deviceInfo.data;
}
