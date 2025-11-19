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

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:receive_intent/receive_intent.dart';

class IntentState {}

abstract class IntentAction extends IntentState {
  final String action;
  final Map<String, dynamic>? parameters;

  IntentAction({required this.action, this.parameters});
}

class IntentReceive extends IntentAction {
  IntentReceive({required super.action, super.parameters});
}

class IntentStart extends IntentAction {
  IntentStart({required super.action, super.parameters});
}

class IntentCubit extends Cubit<IntentState> {
  StreamSubscription<Intent?>? _subscription;

  IntentCubit() : super(IntentState()) {
    _init();
  }

  void _init() {
    ReceiveIntent.getInitialIntent().then((intent) {
      if (intent != null) {
        // android.intent.action.MAIN
        // print('startIntent is ${intent.action}');
        emit(
          IntentStart(action: intent.action ?? '', parameters: intent.extra),
        );
      }
    });

    _subscription = ReceiveIntent.receivedIntentStream.listen(
      (Intent? intent) {
        // print('intent $intent');
        // print(intent?.action);
        // print(intent?.extra);
        // print(intent?.fromPackageName);
        if (intent != null) {
          emit(
            IntentReceive(
              action: intent.action ?? '',
              parameters: intent.extra,
            ),
          );
        }
      },
      onError: (dynamic err) {
        // print(err);
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
