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

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:takeout_lib/cache/json_repository.dart';
import 'package:takeout_lib/cache/prune.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/context/bloc.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/tokens/repository.dart';

import 'app.dart';
import 'context.dart';

class AppBloc extends TakeoutBloc {
  @override
  List<SingleChildWidget> blocs() {
    return List<SingleChildWidget>.from(super.blocs())
      ..add(BlocProvider(create: (_) => AppCubit()));
  }

  @override
  void onNowPlayingChange(BuildContext context, Spiff spiff, bool autoplay) {
    super.onNowPlayingChange(context, spiff, autoplay);
    // include in history and show the player
    context.history.add(spiff: Spiff.cleanup(spiff));
    context.app.showPlayer();
  }

  @override
  ClientRepository createClientRepository({
    required SettingsRepository settingsRepository,
    required TokenRepository tokenRepository,
    required JsonCacheRepository jsonCacheRepository,
    String? userAgent,
  }) {
    return super.createClientRepository(
      userAgent: 'Takeout-App/$appVersion (takeoutfm.com; ${Platform.operatingSystem})',
      settingsRepository: settingsRepository,
      tokenRepository: tokenRepository,
      jsonCacheRepository: jsonCacheRepository,
    );
  }
}

mixin AppBlocState {
  void appInitState(BuildContext context) {
    if (context.tokens.state.tokens.authenticated) {
      // restore authenticated state
      context.app.authenticated();
    }

    // prune incomplete/partial downloads
    pruneCache(context.spiffCache.repository, context.trackCache.repository);
  }

  void appDispose() {
  }
}
