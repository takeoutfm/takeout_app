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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:takeout_lib/cache/json_repository.dart';
import 'package:takeout_lib/cache/prune.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/context/bloc.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/playing.dart';
import 'package:takeout_lib/player/provider.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/tokens/tokens.dart';

import 'app.dart';
import 'context.dart';

class AppBloc extends TakeoutBloc {
  @override
  List<SingleChildWidget> blocs() {
    return List<SingleChildWidget>.from(super.blocs())
      ..add(BlocProvider(create: (_) => AppCubit()));
  }

  @override
  ClientRepository createClientRepository({
    required SettingsRepository settingsRepository,
    required TokenRepository tokenRepository,
    required JsonCacheRepository jsonCacheRepository,
    String? userAgent,
  }) {
    return super.createClientRepository(
      userAgent:
          'TakeoutFM-Watch/$appVersion (takeoutfm.com; ${Platform.operatingSystem})',
      settingsRepository: settingsRepository,
      tokenRepository: tokenRepository,
      jsonCacheRepository: jsonCacheRepository,
    );
  }

  @override
  Player createPlayer(BuildContext context,
      {PositionInterval? positionInterval}) {
    return super.createPlayer(context,
        positionInterval: PositionInterval(
            steps: 100,
            minPeriod: const Duration(seconds: 3),
            maxPeriod: const Duration(seconds: 5)));
  }

  @override
  List<SingleChildWidget> listeners(BuildContext context) {
    final list = List<SingleChildWidget>.from(super.listeners(context));
    list.add(BlocListener<TokensCubit, TokensState>(listener: (context, state) {
      if (state.tokens.authenticated) {
        context.app.authenticated();
      }
    }));
    return list;
  }

  @override
  void onNowPlayingChange(BuildContext context, NowPlayingChange state) {
    super.onNowPlayingChange(context, state);
    addSpiffHistory(context, state.nowPlaying.spiff);
    if (state.nowPlaying.spiff.isNotEmpty) {
      context.app.nowPlaying(state.nowPlaying.spiff);
    }
  }

  @override
  void onNowPlayingIndexChange(
      BuildContext context, NowPlayingIndexChange state) {
    super.onNowPlayingIndexChange(context, state);
    updateSpiffHistory(context, state);
  }

  @override
  void onNowPlayingListenChange(
      BuildContext context, NowPlayingListenChange state) {
    super.onNowPlayingListenChange(context, state);
    addTrackHistory(context, state);
  }
}

mixin AppBlocState {
  void appInitState(BuildContext context) {
    if (context.tokens.state.tokens.authenticated) {
      // restore authenticated state
      context.app.authenticated();
    }
    // prune incomplete/partial downloads
    pruneCache(
      spiffCache: context.spiffCache,
      trackCache: context.trackCache,
      settings: context.settings,
    );
  }

  void appDispose() {}
}
