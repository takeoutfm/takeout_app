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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nested/nested.dart';
import 'package:path_provider/path_provider.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/provider.dart';
import 'package:takeout_lib/browser/repository.dart';
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
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/history/repository.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/intent/intent.dart';
import 'package:takeout_lib/listen/repository.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/media_type/repository.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/playing.dart';
import 'package:takeout_lib/player/playlist.dart';
import 'package:takeout_lib/player/provider.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/repository.dart';
import 'package:takeout_lib/stats/stats.dart';
import 'package:takeout_lib/subscribed/repository.dart';
import 'package:takeout_lib/subscribed/subscribed.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/tokens/tokens.dart';

import 'context.dart';

class TakeoutBloc {
  static late Directory _appDir;

  static Future<void> initStorage() async {
    _appDir = await getApplicationDocumentsDirectory();
    final storageDir = HydratedStorageDirectory('${_appDir.path}/state');
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

    final mediaTypeRepository = MediaTypeRepository();

    final statsRepository = StatsRepository();

    final subscribedRepository = SubscribedRepository();

    final mediaRepository = MediaRepository(
      clientRepository: clientRepository,
      historyRepository: historyRepository,
      settingsRepository: settingsRepository,
      spiffCacheRepository: spiffCacheRepository,
      mediaTypeRepository: mediaTypeRepository,
      subscribedRepository: subscribedRepository,
      offsetCacheRepository: offsetCacheRepository,
      trackCacheRepository: trackCacheRepository,
    );

    final listenRepository = ListenRepository(
        settingsRepository: settingsRepository,
        clientRepository: clientRepository);

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
      RepositoryProvider(create: (_) => mediaRepository),
      RepositoryProvider(create: (_) => listenRepository),
      RepositoryProvider(create: (_) => mediaTypeRepository),
      RepositoryProvider(create: (_) => subscribedRepository),
      RepositoryProvider(create: (_) => statsRepository),
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
      BlocProvider(
          lazy: false,
          create: (context) {
            final nowPlaying = NowPlayingCubit();
            context
                .read<MediaRepository>()
                .init(createMediaPlayer(nowPlaying, context));
            return nowPlaying;
          }),
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
          create: (context) => IndexCubit(context.read<ClientRepository>())),
      BlocProvider(
          lazy: false,
          create: (context) {
            final mediaType = MediaTypeCubit();
            context.read<MediaTypeRepository>().init(mediaType);
            return mediaType;
          }),
      BlocProvider(
          lazy: false,
          create: (context) {
            final subscribed =
                SubscribedCubit(context.read<ClientRepository>());
            context.read<SubscribedRepository>().init(subscribed);
            return subscribed;
          }),
      BlocProvider(lazy: false, create: (context) => IntentCubit()),
      BlocProvider(
          lazy: false,
          create: (context) {
            final stats = StatsCubit();
            context.read<StatsRepository>().init(stats);
            return stats;
          }),
    ];
  }

  List<SingleChildWidget> listeners(BuildContext context) {
    return [
      BlocListener<NowPlayingCubit, NowPlayingState>(
          listenWhen: (_, state) =>
              state is NowPlayingChange ||
              state is NowPlayingIndexChange ||
              state is NowPlayingListenChange ||
              state is NowPlayingRepeatChange,
          listener: (context, state) {
            if (state is NowPlayingChange) {
              onNowPlayingChange(context, state);
            } else if (state is NowPlayingIndexChange) {
              onNowPlayingIndexChange(context, state);
            } else if (state is NowPlayingListenChange) {
              onNowPlayingListenChange(context, state);
            } else if (state is NowPlayingRepeatChange) {
              onNowPlayingRepeatChange(context, state);
            }
          }),
      BlocListener<Player, PlayerState>(
          listenWhen: (_, state) =>
              state is PlayerReady ||
              state is PlayerLoad ||
              state is PlayerPlay ||
              state is PlayerPause ||
              state is PlayerTrackListen ||
              state is PlayerIndexChange ||
              state is PlayerTrackEnd ||
              state is PlayerRepeatModeChange,
          listener: (context, state) {
            if (state is PlayerReady) {
              _onPlayerReady(context, state);
            } else if (state is PlayerLoad) {
              _onPlayerLoad(context, state);
            } else if (state is PlayerPlay) {
              _onPlayerPlay(context, state);
            } else if (state is PlayerPause) {
              _onPlayerPause(context, state);
            } else if (state is PlayerTrackListen) {
              _onPlayerTrackListen(context, state);
            } else if (state is PlayerIndexChange) {
              _onPlayerIndexChange(context, state);
            } else if (state is PlayerTrackEnd) {
              _onPlayerTrackEnd(context, state);
            } else if (state is PlayerRepeatModeChange) {
              _onPlayerRepeatModeChange(context, state);
            }
          }),
      BlocListener<PlaylistCubit, PlaylistState>(
          listenWhen: (_, state) =>
              state is PlaylistChange || state is PlaylistSync,
          listener: (context, state) {
            if (state is PlaylistChange) {
              _onPlaylistChange(context, state);
            } else if (state is PlaylistSync) {
              if (state.spiff != context.nowPlaying.state.nowPlaying.spiff) {
                _onPlaylistSyncChange(context, state);
              }
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
      BlocListener<IntentCubit, IntentState>(
          listenWhen: (_, state) =>
              state is IntentStart || state is IntentReceive,
          listener: (context, state) {
            if (state is IntentStart) {
              onIntentStart(context, state);
            } else if (state is IntentReceive) {
              onIntentReceive(context, state);
            }
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
        trackResolver: context.read<MediaTrackResolver>(),
        mediaRepository: context.read<MediaRepository>());
  }

  MediaPlayer createMediaPlayer(
      NowPlayingCubit nowPlaying, BuildContext context) {
    final settingsRepository = context.read<SettingsRepository>();
    return BaseMediaPlayer(nowPlaying, settingsRepository);
  }

  /// Process start intent
  void onIntentStart(BuildContext context, IntentStart intent) {}

  /// Process received intent
  void onIntentReceive(BuildContext context, IntentReceive intent) {}

  /// NowPlaying manages the playlist that should be playing.
  void onNowPlayingChange(BuildContext context, NowPlayingChange state) {
    if (state.nowPlaying.autoCache) {
      // add spiff to downloads. tracks will be downloaded during playback
      context.spiffCache.add(state.nowPlaying.spiff);
    }
    // load now playing playlist into player
    context.player.load(
      state.nowPlaying.spiff,
      autoPlay: state.nowPlaying.autoPlay,
      autoCache: state.nowPlaying.autoCache,
      repeat: state.nowPlaying.repeat,
    );
  }

  /// NowPlaying playlist index change event
  void onNowPlayingIndexChange(
      BuildContext context, NowPlayingIndexChange state) {
    _onNowPlayingIndexChange(context, state);
  }

  void _onNowPlayingIndexChange(
      BuildContext context, NowPlayingIndexChange state) {
    final startedAt = state.nowPlaying.startedAt(state.nowPlaying.spiff.index);
    if (startedAt != null) {
      final track =
          state.nowPlaying.spiff.playlist.tracks[state.nowPlaying.spiff.index];
      context.listenRepository.playingNow(track);
    }
  }

  /// NowPlaying track listen change
  void onNowPlayingListenChange(
      BuildContext context, NowPlayingListenChange state) {
    _onNowPlayingListenChange(context, state);
  }

  void _onNowPlayingListenChange(
      BuildContext context, NowPlayingListenChange state) {
    final listenedAt =
        state.nowPlaying.listenedAt(state.nowPlaying.spiff.index);
    if (listenedAt != null) {
      final track = state.nowPlaying.spiff[state.nowPlaying.spiff.index];

      // submit takeout activity
      _updateTrackActivity(context, track, listenedAt);

      // submit listen to listenbrainz
      context.listenRepository.listenedAt(track, listenedAt);
    }
  }

  /// NowPlaying repeat mode change
  void onNowPlayingRepeatChange(
      BuildContext context, NowPlayingRepeatChange state) {
    final repeat = state.nowPlaying.repeat;
    if (repeat != null) {
      context.player.repeatMode(repeat);
    }
  }

  void _onPlaylistChange(BuildContext context, PlaylistState state) {
    context.play(state.spiff);
  }

  void _onPlaylistSyncChange(BuildContext context, PlaylistState state) {
    context.play(state.spiff, autoPlay: false);
  }

  /// Restore playlist once the player is ready.
  void _onPlayerReady(BuildContext context, PlayerReady state) {
    // nowPlaying synchronously rehydrated so it's safe here to assume
    // that nowPlaying is ready to be played once the player is ready.
    context.nowPlaying.restore();

    final player = context.player;
    player.stream.timeout(const Duration(minutes: 1), onTimeout: (_) {
      player.stop();
    }).listen((event) {});
  }

  void _onPlayerLoad(BuildContext context, PlayerLoad state) {
    if (state.autoPlay) {
      context.player.play();
    }
  }

  void _onPlayerPlay(BuildContext context, PlayerPlay state) {}

  void _onPlayerPause(BuildContext context, PlayerPause state) {
    saveProgress(context, state);
  }

  void _onPlayerIndexChange(BuildContext context, PlayerIndexChange state) {
    context.nowPlaying.index(state.currentIndex);
  }

  void _onPlayerTrackEnd(BuildContext context, PlayerTrackEnd state) {
    saveProgress(context, state);
  }

  void _onPlayerTrackListen(BuildContext context, PlayerTrackListen state) {
    if (state.spiff.isMusic()) {
      final index = state.currentIndex;
      if (context.nowPlaying.state.nowPlaying.listenedTo(index) == false) {
        final listenedAt = DateTime.now(); // TODO is now ok?
        context.nowPlaying.listened(index, listenedAt);
      }
    }
  }

  void _onPlayerRepeatModeChange(
      BuildContext context, PlayerRepeatModeChange state) {
    context.nowPlaying.repeatMode(state.repeat);
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
        ? context.allowMobileDownload
        : true) {
      context.downloads.check();
    }
  }

  void _updateTrackActivity(
      BuildContext context, Entry track, DateTime listenedAt) {
    if (context.enableTrackActivity) {
      final events = Events(
        trackEvents: [
          TrackEvent.from(track.etag, listenedAt),
        ],
      );
      context.clientRepository.updateActivity(events);
    }
  }

  // override this to change behavior
  void saveProgress(BuildContext context, PlayerPositionState state) {
    if (state.buffering == false) {
      // print('saveProgress $state ${state.position} ${state.buffering}');
      if (state.spiff.isPodcast()) {
        // save podcast progress at server
        final currentTrack = state.currentTrack;
        if (currentTrack != null) {
          context.updateProgress(currentTrack.etag,
              position: state.position, duration: state.duration);
        }
      }
      if (state.spiff.isStream() == false) {
        // save progress in history for quick restore
        updateSpiffHistoryPosition(context, state);
      }
    }
  }

  void updateSpiffHistoryPosition(
      BuildContext context, PlayerPositionState state) {
    final spiff =
        state.spiff.copyWith(position: state.position.inSeconds.toDouble());
    if (spiff.isNotEmpty && spiff.isStream() == false) {
      context.history.add(spiff: Spiff.cleanup(spiff));
    }
  }

  // add spiff to history
  void addSpiffHistory(BuildContext context, Spiff spiff) {
    if (spiff.isNotEmpty) {
      context.history.add(spiff: Spiff.cleanup(spiff));
    }
  }

  // update spiff history with index
  void updateSpiffHistory(BuildContext context, NowPlayingIndexChange state) {
    final spiff = state.nowPlaying.spiff;
    if (spiff.isNotEmpty) {
      context.history.add(spiff: Spiff.cleanup(spiff));
    }
  }

  // add to local track history
  void addTrackHistory(BuildContext context, NowPlayingListenChange state) {
    final listenedAt =
        state.nowPlaying.listenedAt(state.nowPlaying.spiff.index);
    if (listenedAt != null) {
      final track = state.nowPlaying.spiff[state.nowPlaying.spiff.index];
      context.history.add(track: track, dateTime: listenedAt);
    }
  }
}

class BaseMediaPlayer implements MediaPlayer {
  final NowPlayingCubit player;
  final SettingsRepository settingsRepository;

  BaseMediaPlayer(this.player, this.settingsRepository);

  @override
  void playSpiff(Spiff spiff) {
    player.add(spiff,
        autoCache: settingsRepository.settings?.autoCache,
        autoPlay: settingsRepository.settings?.autoPlay);
  }

  @override
  void playMovie(Movie movie) {
    throw UnimplementedError;
  }
}
