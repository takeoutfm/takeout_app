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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nested/nested.dart';
import 'package:path_provider/path_provider.dart';
import 'package:takeout_lib/art/provider.dart';
import 'package:takeout_lib/cache/json_repository.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/cache/track_repository.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_lib/connectivity/repository.dart';
import 'package:takeout_lib/db/search.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/playing.dart';
import 'package:takeout_lib/player/playlist.dart';
import 'package:takeout_lib/player/provider.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/tokens/tokens.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/repository.dart';

import 'context.dart';

class TakeoutBloc {
  static late Directory _appDir;

  static Future<void> initStorage() async {
    _appDir = await getApplicationDocumentsDirectory();
    final storageDir = Directory('${_appDir.path}/state');
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: storageDir);
  }

  Widget init(BuildContext context, {required Widget child}) {
    return MultiRepositoryProvider(
        providers: repositories(_appDir),
        child: MultiBlocProvider(
            providers: blocs(),
            child: MultiBlocListener(
                listeners: listeners(context), child: child)));
  }

  List<SingleChildWidget> repositories(Directory directory) {
    final d = (String name) => Directory('${directory.path}/$name');

    final settingsRepository = SettingsRepository();

    final trackCacheRepository =
        TrackCacheRepository(directory: d('track_cache'));

    final jsonCacheRepository = JsonCacheRepository(directory: d('json_cache'));

    final offsetCacheRepository =
        OffsetCacheRepository(directory: d('offset_cache'));

    final spiffCacheRepository =
        SpiffCacheRepository(directory: d('spiff_cache'));

    final tokenRepository = TokenRepository();

    final clientRepository = createClientRepository(
        settingsRepository: settingsRepository,
        tokenRepository: tokenRepository,
        jsonCacheRepository: jsonCacheRepository);

    final connectivityRepository = ConnectivityRepository();

    final search = Search(clientRepository: clientRepository);

    final trackResolver =
        MediaTrackResolver(trackCacheRepository: trackCacheRepository);

    final historyRepository = HistoryRepository(directory: directory);

    final artProvider = ArtProvider(settingsRepository, clientRepository);

    return [
      RepositoryProvider(create: (_) => search),
      RepositoryProvider(create: (_) => settingsRepository),
      RepositoryProvider(create: (_) => trackCacheRepository),
      RepositoryProvider(create: (_) => jsonCacheRepository),
      RepositoryProvider(create: (_) => offsetCacheRepository),
      RepositoryProvider(create: (_) => spiffCacheRepository),
      RepositoryProvider(create: (_) => clientRepository),
      RepositoryProvider(create: (_) => connectivityRepository),
      RepositoryProvider(create: (_) => tokenRepository),
      RepositoryProvider(create: (_) => trackResolver),
      RepositoryProvider(create: (_) => historyRepository),
      RepositoryProvider(create: (_) => artProvider),
    ];
  }

  List<SingleChildWidget> blocs() {
    return [
      BlocProvider(
          lazy: false,
          create: (context) {
            final settings = SettingsCubit();
            context.read<SettingsRepository>().init(settings);
            return settings;
          }),
      BlocProvider(create: (_) => MediaTypeCubit()),
      BlocProvider(create: (_) => NowPlayingCubit()),
      BlocProvider(
          create: (context) => PlaylistCubit(context.read<ClientRepository>())),
      BlocProvider(
          create: (context) =>
              ConnectivityCubit(context.read<ConnectivityRepository>())),
      BlocProvider(create: (context) {
        final tokens = TokensCubit();
        context.read<TokenRepository>().init(tokens);
        return tokens;
      }),
      BlocProvider(create: (context) => createPlayer(context)),
      BlocProvider(
          create: (context) =>
              SpiffCacheCubit(context.read<SpiffCacheRepository>())),
      BlocProvider(
          lazy: false,
          create: (context) => OffsetCacheCubit(
              context.read<OffsetCacheRepository>(),
              context.read<ClientRepository>())),
      BlocProvider(
          create: (context) => DownloadCubit(
                trackCacheRepository: context.read<TrackCacheRepository>(),
                clientRepository: context.read<ClientRepository>(),
              )),
      BlocProvider(
          create: (context) => TrackCacheCubit(
                context.read<TrackCacheRepository>(),
              )),
      BlocProvider(
          create: (context) => HistoryCubit(context.read<HistoryRepository>())),
      BlocProvider(
          create: (context) => IndexCubit(context.read<ClientRepository>()))
    ];
  }

  List<SingleChildWidget> listeners(BuildContext context) {
    return [
      BlocListener<NowPlayingCubit, NowPlayingState>(
          listenWhen: (_, state) => state is NowPlayingChange,
          listener: (context, state) {
            if (state is NowPlayingChange) {
              onNowPlayingChange(context, state.spiff, state.autoplay);
            }
          }),
      BlocListener<Player, PlayerState>(
          listenWhen: (_, state) =>
              state is PlayerReady ||
              state is PlayerLoad ||
              state is PlayerPlay ||
              state is PlayerPause ||
              state is PlayerIndexChange ||
              state is PlayerTrackEnd,
          listener: (context, state) {
            if (state is PlayerReady) {
              _onPlayerReady(context, state);
            } else if (state is PlayerLoad) {
              _onPlayerLoad(context, state);
            } else if (state is PlayerPlay) {
              _onPlayerPlay(context, state);
            } else if (state is PlayerPause) {
              _onPlayerPause(context, state);
            } else if (state is PlayerIndexChange) {
              _onPlayerIndexChange(context, state);
            } else if (state is PlayerTrackEnd) {
              _onPlayerTrackEnd(context, state);
            }
          }),
      BlocListener<PlaylistCubit, PlaylistState>(
          listenWhen: (_, state) => state is PlaylistChange,
          listener: (context, state) {
            if (state is PlaylistChange) {
              _onPlaylistChange(context, state);
            }
          }),
      BlocListener<DownloadCubit, DownloadState>(
          listenWhen: (_, state) =>
              state is DownloadAdd ||
              state is DownloadComplete ||
              state is DownloadError,
          listener: (context, state) {
            if (state is DownloadComplete) {
              _onDownloadComplete(context, state);
            }
            _onDownloadChange(context, state);
          }),
    ];
  }

  ClientRepository createClientRepository({
    required SettingsRepository settingsRepository,
    required TokenRepository tokenRepository,
    required JsonCacheRepository jsonCacheRepository,
    String? userAgent,
  }) {
    return ClientRepository(
        userAgent: userAgent,
        settingsRepository: settingsRepository,
        tokenRepository: tokenRepository,
        jsonCacheRepository: jsonCacheRepository);
  }

  Player createPlayer(BuildContext context,
      {PositionInterval? positionInterval}) {
    return Player(
        positionInterval: positionInterval,
        offsetRepository: context.read<OffsetCacheRepository>(),
        settingsRepository: context.read<SettingsRepository>(),
        tokenRepository: context.read<TokenRepository>(),
        trackResolver: context.read<MediaTrackResolver>());
  }

  /// NowPlaying manages the playlist that should be playing.
  void onNowPlayingChange(BuildContext context, Spiff spiff, bool autoplay) {
    // load now playing playlist into player
    context.player.load(spiff, autoplay: autoplay);
  }

  void _onPlaylistChange(BuildContext context, PlaylistChange state) {
    context.play(state.spiff);
  }

  /// Restore playlist once the player is ready.
  void _onPlayerReady(BuildContext context, PlayerReady state) {
    final nowPlaying = context.nowPlaying.state;
    onNowPlayingChange(context, nowPlaying.spiff, false);

    context.player.stream.timeout(const Duration(minutes: 1), onTimeout: (_) {
      context.player.stop();
    }).listen((event) {});
  }

  void _onPlayerLoad(BuildContext context, PlayerLoad state) {
    if (state.autoplay) {
      context.player.play();
    }
  }

  void _onPlayerPlay(BuildContext context, PlayerPlay state) {}

  void _updateProgress(BuildContext context, PlayerPositionState state) {
    if (state.spiff.isPodcast()) {
      final currentTrack = state.currentTrack;
      if (currentTrack != null) {
        context.updateProgress(currentTrack.etag,
            position: state.position, duration: state.duration);
      }
    }
  }

  void _onPlayerPause(BuildContext context, PlayerPause state) {
    _updateProgress(context, state);
  }

  void _onPlayerIndexChange(BuildContext context, PlayerIndexChange state) {
    context.nowPlaying.index(state.currentIndex);
  }

  void _onPlayerTrackEnd(BuildContext context, PlayerTrackEnd state) {
    _updateProgress(context, state);
  }

  void _onDownloadComplete(BuildContext context, DownloadComplete state) {
    // add completed download to TrackCache
    final download = state.get(state.id);
    final file = download?.file;
    if (download != null && file != null) {
      context.trackCache.add(state.id, file);
    }
  }

  void _onDownloadChange(BuildContext context, DownloadState state) {
    // check if downloads should be started
    // TODO this will only prevent the next download from starting
    // the current one will continue if network switched from to mobile
    // during the download.
    if (context.connectivity.state.mobile
        ? context.settings.state.settings.allowMobileDownload
        : true) {
      context.downloads.check();
    }
  }
}
