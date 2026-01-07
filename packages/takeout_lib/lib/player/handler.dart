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

// This file is based on the audio_service example app located here:
// https://github.com/ryanheise/audio_service

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:takeout_lib/browser/repository.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/util.dart';

import 'provider.dart';
import 'repeat.dart';

extension TakeoutMediaItem on MediaItem {
  bool isLocalFile() => id.startsWith(RegExp(r'^file'));

  bool isRemote() => id.startsWith(RegExp(r'^http'));
}

class TakeoutPlayerHandler extends BaseAudioHandler with QueueHandler {
  final MediaTrackResolver trackResolver;
  final TokenRepository tokenRepository;
  final SettingsRepository settingsRepository;
  final OffsetCacheRepository offsetRepository;
  final MediaRepository mediaRepository;

  final AudioPlayer _player = AudioPlayer(maxSkipsOnError: 1);
  final PlayCallback onPlay;
  final PauseCallback onPause;
  final StoppedCallback onStop;
  final IndexCallback onIndexChange;
  final PositionCallback onPositionChange;
  final PositionCallback onDurationChange;
  final ListenCallback onListen;
  final TrackChangeCallback onTrackChange;
  final TrackEndCallback onTrackEnd;
  final RepeatModeChangeCallback onRepeatModeChange;
  final LiveTrackChangeCallback onLiveTrackChange;

  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _listens = ExpiringSet<String>(const Duration(minutes: 15));

  Spiff _spiff = Spiff.empty();
  final _queue = <MediaItem>[];
  final _mapped = <String, Entry>{};

  final Duration _skipToBeginningInterval;
  final int _positionSteps;
  final Duration _minPositionPeriod;
  final Duration _maxPositionPeriod;

  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;

  TakeoutPlayerHandler._({
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onIndexChange,
    required this.onPositionChange,
    required this.onDurationChange,
    required this.onListen,
    required this.onTrackChange,
    required this.onTrackEnd,
    required this.onRepeatModeChange,
    required this.onLiveTrackChange,
    required this.trackResolver,
    required this.tokenRepository,
    required this.settingsRepository,
    required this.offsetRepository,
    required this.mediaRepository,
    Duration? skipToBeginningInterval,
    int? positionSteps,
    Duration? minPositionPeriod,
    Duration? maxPositionPeriod,
  }) : _skipToBeginningInterval =
           skipToBeginningInterval ?? const Duration(seconds: 10),
       _positionSteps = positionSteps ?? 800,
       _minPositionPeriod =
           minPositionPeriod ?? const Duration(milliseconds: 16),
       _maxPositionPeriod =
           maxPositionPeriod ?? const Duration(milliseconds: 200) {
    _init();
  }

  static Future<TakeoutPlayerHandler> create({
    required MediaTrackResolver trackResolver,
    required TokenRepository tokenRepository,
    required SettingsRepository settingsRepository,
    required OffsetCacheRepository offsetRepository,
    required MediaRepository mediaRepository,
    required PlayCallback onPlay,
    required PauseCallback onPause,
    required StoppedCallback onStop,
    required IndexCallback onIndexChange,
    required PositionCallback onPositionChange,
    required PositionCallback onDurationChange,
    required ListenCallback onListen,
    required TrackChangeCallback onTrackChange,
    required TrackEndCallback onTrackEnd,
    required RepeatModeChangeCallback onRepeatModeChange,
    required LiveTrackChangeCallback onLiveTrackChange,
    Duration? skipBeginningInterval,
    Duration? fastForwardInterval,
    Duration? rewindInterval,
    int? positionSteps,
    Duration? minPositionPeriod,
    Duration? maxPositionPeriod,
  }) async {
    Map<String, dynamic>? rootExtras;
    if (mediaRepository.getSearchSupported()) {
      rootExtras = {'android.media.browse.SEARCH_SUPPORTED': true};
    }
    return await AudioService.init(
      builder: () => TakeoutPlayerHandler._(
        onPlay: onPlay,
        onPause: onPause,
        onStop: onStop,
        onIndexChange: onIndexChange,
        onPositionChange: onPositionChange,
        onDurationChange: onDurationChange,
        onListen: onListen,
        onTrackChange: onTrackChange,
        onTrackEnd: onTrackEnd,
        onRepeatModeChange: onRepeatModeChange,
        onLiveTrackChange: onLiveTrackChange,
        trackResolver: trackResolver,
        tokenRepository: tokenRepository,
        settingsRepository: settingsRepository,
        offsetRepository: offsetRepository,
        mediaRepository: mediaRepository,
        skipToBeginningInterval: skipBeginningInterval,
        positionSteps: positionSteps,
        minPositionPeriod: minPositionPeriod,
        maxPositionPeriod: maxPositionPeriod,
      ),
      config: AudioServiceConfig(
        androidNotificationIcon: 'drawable/ic_stat_name',
        androidNotificationChannelId: 'com.takeoutfm.channel.audio',
        androidNotificationChannelName: 'TakeoutFM Audio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidBrowsableRootExtras: rootExtras,
        fastForwardInterval: fastForwardInterval ?? const Duration(seconds: 30),
        rewindInterval: rewindInterval ?? const Duration(seconds: 10),
      ),
    );
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // index changes
    // _subscriptions.add(_player.currentIndexStream.listen((index) {
    //   if (index == null) {
    //     // player sends index as null at startup
    //     return;
    //   }
    //   print('indexChange $index (${_spiff.index})');
    //   if (index >= 0 && index < _spiff.length) {
    //     // update the current media item
    //     mediaItem.add(_queue[index]);
    //
    //     // update the spiff
    //     if (index != _spiff.index) {
    //       _spiff = _spiff.copyWith(index: index);
    //       onIndexChange(_spiff, _player.playing);
    //     }
    //   }
    // }));

    // media duration changes
    // _subscriptions.add(_player.durationStream.listen((duration) {
    //   print('got duration ${_spiff.index} $duration');
    //   if (duration != null) {
    //     final index = _spiff.index;
    //     final item = _queue[index].copyWith(duration: duration);
    //     _queue[index] = item;
    //
    //     // update the current media item
    //     mediaItem.add(item);
    //
    //     // update the media queue
    //     queue.add(_queue);
    //
    //     onDurationChange(_spiff, duration, _player.position, _player.playing);
    //   }
    // }));

    // player position changes
    _subscriptions.add(
      _player
          .createPositionStream(
            steps: _positionSteps,
            minPeriod: _minPositionPeriod,
            maxPeriod: _maxPositionPeriod,
          )
          .listen((position) {
            if (_player.currentIndex == null) {
              return;
            }
            onPositionChange(
              _spiff,
              _player.duration ?? Duration.zero,
              _player.position,
              _player.playing,
            );
          }),
    );

    // use default positionStream
    // _subscriptions.add(_player.positionStream.listen((position) {
    //   if (_player.currentIndex == null) {
    //     return;
    //   }
    //   onPositionChange(_spiff, _player.duration ?? Duration.zero,
    //       _player.position, _player.playing);
    // }));

    // TODO onTrackEnd isn't called right now
    // FIXME: discontinuity doesn't work due to:
    // - setAudioSource triggers events
    // - switching spiffs is seen as a autoAdvance - seems wrong
    // - onTrackEnd is called with new spiff, no longer have old one
    // - previousEvent doesn't have enough to reconstruct previous state

    // _player.positionDiscontinuityStream.listen((discontinuity) {
    //   if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
    //     final previousIndex = discontinuity.previousEvent.currentIndex;
    //     final duration = discontinuity.previousEvent.duration ?? Duration.zero;
    //     final position = discontinuity.previousEvent.updatePosition;
    //     if (previousIndex != null) {
    //       onTrackEnd(
    //           _spiff, previousIndex, duration, position, _player.playing);
    //     }
    //   }
    // });

    // icy metadata changes
    _subscriptions.add(
      _player.icyMetadataStream.listen((event) {
        // TODO icy events are sometimes sent for regular media so ignore them.
        if (_spiff.isLive && event != null) {
          final title = event.info?.title;
          if (title == null || title == mediaItem.value?.title) {
            // only proceed if there's a new title
            // just_audio can send title as null and then the previous
            // value again so check against the latest mediaItem title also
            return;
          }

          // use event image if possible, fallback to spiff
          final index = _spiff.index;
          final image = event.info?.url ?? _spiff[index].image;
          final icyTrack = IcyTrack(_spiff.creator ?? '', title, image);

          // update the current media item title and image
          var item = _queue[index];
          item = item.copyWith(
            title: icyTrack.title,
            artUri: Uri.parse(icyTrack.image),
          );
          mediaItem.add(item);

          // update the media queue
          _queue[index] = item;
          queue.add(_queue);

          // update the current spiff
          _spiff = _spiff.updateAt(
            index,
            _spiff[index].copyWith(
              title: icyTrack.title,
              image: icyTrack.image,
            ),
          );
          onTrackChange(
            _spiff,
            index,
            title: icyTrack.title,
            image: icyTrack.image,
          );

          // update LiveTrack change
          onLiveTrackChange(_spiff, icyTrack);
        }
      }),
    );

    // send state from the audio player to AudioService clients.
    _subscriptions.add(
      _player.playbackEventStream.listen((state) {
        final index = state.currentIndex;
        if (index != null) {
          if (index != _spiff.index) {
            _indexChange(index);
          }
          if (_queue[index].duration != state.duration) {
            _durationChange(state.duration);
          }
        }
        _broadcastState(state);
      }),
    );

    // automatically go to the beginning of queue & stop.
    _subscriptions.add(
      _player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          skipToQueueItem(0).whenComplete(() => stop());
          onStop(_spiff);
        }
      }),
    );

    // player state changes (playing/paused)
    _subscriptions.add(
      _player.playerStateStream.distinct().listen((state) {
        if (_player.currentIndex == null) {
          return;
        }
        final buffering =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
        final duration = _player.duration ?? Duration.zero;
        if (state.playing) {
          onPlay(_spiff, duration, _player.position, buffering);
        } else if (state.processingState != ProcessingState.idle) {
          // FIXME
          // There's still a problem here where during load() the initialPosition
          // is reset back to 0 and onPause is sent incorrectly. This gets fixed
          // later in skipToQueue.
          onPause(_spiff, duration, _player.position, buffering);
        }
      }),
    );

    // create a stream to update progress less frequently than position updates
    _subscriptions.add(
      _player
          .createPositionStream(
            steps: 100,
            minPeriod: const Duration(seconds: 5),
            maxPeriod: const Duration(seconds: 10),
          )
          .listen((position) {
            if (_player.processingState == ProcessingState.ready) {
              final item = mediaItem.value;
              if (item != null) {
                final key = '${item.artist}/${item.title}';
                if (_listens.contains(key) == false) {
                  final duration = _player.duration ?? Duration.zero;
                  if (considerListened(position, duration)) {
                    _listens.add(key);
                    onListen(_spiff, duration, position, _player.playing);
                  }
                }
              }
            }
          }),
    );
  }

  void _durationChange(Duration? duration) {
    if (duration != null) {
      final index = _spiff.index;
      final item = _queue[index].copyWith(duration: duration);
      _queue[index] = item;

      // update the current media item
      mediaItem.add(item);

      // update the media queue
      queue.add(_queue);

      onDurationChange(_spiff, duration, _player.position, _player.playing);
    }
  }

  void _indexChange(int index) {
    if (index >= 0 && index < _spiff.length) {
      // update the current media item
      mediaItem.add(_queue[index]);

      // update the spiff
      if (index != _spiff.index) {
        _spiff = _spiff.copyWith(index: index);
        onIndexChange(_spiff, _player.playing);
      }
    }
  }

  bool considerListened(Duration position, Duration duration) {
    // ListenBrainz guidance:
    // Listens should be submitted for tracks when the user has listened
    // to half the track or 4 minutes of the track, whichever is lower. If the
    // user hasn't listened to 4 minutes or half the track, it doesn't fully
    // count as a listen and should not be submitted.
    if (position > const Duration(minutes: 4)) {
      return true;
    }
    final d = duration * 0.5;
    return duration > Duration.zero && position >= d;
  }

  // void dispose() {
  //   for (var subscription in _subscriptions) {
  //     subscription.cancel();
  //   }
  // }

  Future<MediaItem> _map(bool isLive, Entry entry) async {
    final endpoint = settingsRepository.settings?.endpoint;
    String image = entry.image;
    if (image.startsWith('/img/')) {
      image = '$endpoint$image';
    }
    final uri = await trackResolver.resolve(entry);
    String id = uri.toString();
    if (id.startsWith('/api/') || id.startsWith('/d/')) {
      // TODO should this just do all relative ids? '^/'?
      id = '$endpoint$id';
    }
    return MediaItem(
      id: id,
      album: entry.album,
      title: entry.title,
      artist: entry.creator,
      artUri: Uri.parse(image),
      isLive: isLive,
    );
  }

  Future<List<MediaItem>> _mapAll(bool isLive, List<Entry> tracks) async {
    final list = <MediaItem>[];
    await Future.forEach<Entry>(tracks, (entry) async {
      final item = await _map(isLive, entry);
      _mapped[item.id] = entry;
      list.add(item);
    });
    return list;
  }

  File? _checkPlaybackCache(MediaItem item, Entry entry, bool autoCache) {
    File? cacheFile;
    if (autoCache && item.isRemote() && item.isLive == false) {
      cacheFile = trackResolver.trackCacheRepository.create(entry);
    }
    return cacheFile;
  }

  IndexedAudioSource toAudioSource(
    MediaItem item, {
    Map<String, String>? headers,
    bool? autoCache,
  }) {
    final uri = Uri.parse(item.id);
    final entry = _mapped[item.id];
    IndexedAudioSource? audioSource;

    if (entry != null && entry.size > 0) {
      File? cacheFile = _checkPlaybackCache(item, entry, autoCache ?? false);
      if (cacheFile != null) {
        // only create a caching audio source to create a new cache file
        // during playback, otherwise the uri source below will use the
        // cached file or remote uri as needed.
        // note that the track resolver is responsible for cleaning up
        // incomplete downloads.
        final cachingSource = LockCachingAudioSource(
          uri,
          headers: headers,
          tag: item,
          cacheFile: cacheFile,
        );
        StreamSubscription<double>? subscription;
        subscription = cachingSource.downloadProgressStream.listen((progress) {
          if (progress == 1.0) {
            subscription?.cancel();
            trackResolver.trackCacheRepository.put(entry, cacheFile);
          }
        }, cancelOnError: true);
        audioSource = cachingSource;
      }
    }

    audioSource ??= AudioSource.uri(uri, headers: headers, tag: item);
    return audioSource;
  }

  Future<void> load(
    Spiff spiff, {
    LoadCallback? onLoad,
    bool? autoCache,
    RepeatMode? repeat,
  }) async {
    if (spiff.isEmpty) {
      return;
    }
    _spiff = spiff;
    if (_spiff.index < 0) {
      // TODO server sends -1
      _spiff = _spiff.copyWith(index: 0);
    }
    final index = _spiff.index;

    // build a new MediaItem queue
    _queue.clear();
    _mapped.clear();
    _queue.addAll(await _mapAll(_spiff.isLive, _spiff.playlist.tracks));

    // broadcast queue state
    queue.add(_queue);

    // build audio sources from the queue
    final headers = tokenRepository.addMediaToken();
    final sources = _queue
        .map(
          (item) => toAudioSource(
            item,
            autoCache: autoCache,
            headers: item.isRemote() ? headers : null,
          ),
        )
        .toList();

    // Note: this initialPosition doesn't actually work since the player
    // goes back to zero. skipToQueue below is where restoring position needs
    // to happen.
    final offset = await offsetRepository.get(_spiff[index]);
    final position = offset?.position() ?? Duration.zero;

    // setAudioSource triggers events so use the correct index and position even though
    // skipToQueueItem does the same thing next.
    // also ensure _spiff is correct since events are triggered
    await _player.setAudioSources(
      sources,
      initialIndex: index,
      initialPosition: position,
    );
    // final source = ConcatenatingAudioSource(children: []);
    // await source.addAll(sources);
    // await _player.setAudioSource(source,
    //     initialIndex: index, initialPosition: position);

    await skipToQueueItem(index);

    if (repeat != null) {
      await repeatMode(repeat);
    }

    onLoad?.call(
      _spiff,
      _player.position,
      _player.playing,
      _player.processingState == ProcessingState.loading ||
          _player.processingState == ProcessingState.buffering,
    );
  }

  Future<void> repeatMode(RepeatMode repeat) async {
    await switch (repeat) {
      RepeatMode.none => setRepeatMode(AudioServiceRepeatMode.none),
      RepeatMode.one => setRepeatMode(AudioServiceRepeatMode.one),
      RepeatMode.all => setRepeatMode(AudioServiceRepeatMode.all),
    };
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    Duration? position;

    if (index == -1) {
      // audio_service will send -1 if the current index is 0
      index = 0;
    }

    // restore position from server saved offset
    final offset = await offsetRepository.get(_spiff.playlist.tracks[index]);
    position = offset?.position();

    if (position == null) {
      if (index == _spiff.index && _spiff.position > 0) {
        // restore spiff position
        position = Duration(seconds: _spiff.position.toInt());
        // only use this to restore position once
        _spiff = _spiff.copyWith(position: 0);
      }
    }
    position ??= Duration.zero;

    final currentIndex = _spiff.index;
    if (index == currentIndex - 1) {
      if (_player.position > _skipToBeginningInterval) {
        // skip to beginning before going to previous
        index = currentIndex;
        position = Duration.zero;
      }
    }

    if (index != currentIndex) {
      // TODO - the below is also in the currentIndexStream listener
      // and happening twice. comment for now to see if this is ok.

      // keep the spiff updated
      // _spiff = _spiff.copyWith(index: index);
      // onIndexChange(_spiff, _player.playing);

      // update the current media item
      // mediaItem.add(_queue[index]);

      playbackState.add(playbackState.value.copyWith(queueIndex: index));
    }

    return _player.seek(position, index: index);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index = _queue.indexWhere((e) => e.id == mediaItem.id);
    if (index != -1) {
      return skipToQueueItem(index);
    }
  }

  @override
  Future<void> play() => _player.play();

  Future<void> playIndex(int index) {
    return skipToQueueItem(index).whenComplete(() => play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() => _player.seek(
    _seekCheck(_player.position + AudioService.config.fastForwardInterval),
  );

  @override
  Future<void> rewind() => _player.seek(
    _seekCheck(_player.position - AudioService.config.rewindInterval),
  );

  @override
  Future<void> stop() async {
    await _player.stop();

    // wait for `idle`
    await playbackState.firstWhere(
      (state) => state.processingState == AudioProcessingState.idle,
    );

    // Set the audio_service state to `idle` to deactivate the notification.
    playbackState.add(
      playbackState.value.copyWith(processingState: AudioProcessingState.idle),
    );
  }

  Future<void> dispose() {
    return _player.dispose();
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    return mediaRepository.playFromMediaId(mediaId);
  }

  @override
  Future<List<MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    if (parentMediaId == AudioService.browsableRootId) {
      return mediaRepository.getRoot();
    } else if (parentMediaId == AudioService.recentRootId) {
      return mediaRepository.getRecent();
    }
    return mediaRepository.getChildren(parentMediaId);
  }

  @override
  Future<void> playFromSearch(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    return mediaRepository.playFromSearch(
      query,
      mediaType: MediaType.music,
      extras: extras,
    );
  }

  @override
  Future<List<MediaItem>> search(
    String query, [
    Map<String, dynamic>? extras,
  ]) async {
    return mediaRepository.search(
      query,
      mediaType: MediaType.music,
      extras: extras,
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _repeatMode = repeatMode;
    return switch (repeatMode) {
      AudioServiceRepeatMode.none => _player.setLoopMode(LoopMode.off),
      AudioServiceRepeatMode.one => _player.setLoopMode(LoopMode.one),
      AudioServiceRepeatMode.group ||
      AudioServiceRepeatMode.all => _player.setLoopMode(LoopMode.all),
    }
    // update external state with new repeat mode
    .whenComplete(() => _broadcastState(_player.playbackEvent));
  }

  Duration _seekCheck(Duration pos) {
    if (pos < Duration.zero) {
      return Duration.zero;
    }

    final currentItem = mediaItem.valueOrNull;
    final end = currentItem?.duration;
    if (end != null && pos > end) {
      pos = end;
    }
    return pos;
  }

  MediaControl _loopControl(LoopMode loopMode) {
    // below code is a little more complex to allow for const usage
    return switch (loopMode) {
      LoopMode.off => const MediaControl(
        androidIcon: 'drawable/repeat_24dp',
        label: 'Repeat Off',
        action: MediaAction.custom,
        customAction: CustomMediaAction(
          name: 'setRepeatMode',
          extras: {'mode': 'all'},
        ),
      ),
      LoopMode.all => const MediaControl(
        androidIcon: 'drawable/repeat_on_24dp',
        label: 'Repeat On',
        action: MediaAction.custom,
        customAction: CustomMediaAction(
          name: 'setRepeatMode',
          extras: {'mode': 'one'},
        ),
      ),
      LoopMode.one => const MediaControl(
        androidIcon: 'drawable/repeat_one_on_24dp',
        label: 'Repeat One',
        action: MediaAction.custom,
        customAction: CustomMediaAction(
          name: 'setRepeatMode',
          extras: {'mode': 'none'},
        ),
      ),
    };
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    if (name == 'setRepeatMode') {
      final mode = extras?['mode'] ?? 'none';
      for (var m in RepeatMode.values) {
        if (m.name == mode) {
          // invoke the callback to pass along this request to change
          // the repeat mode. the actual mode change is performed externally.
          onRepeatModeChange(_spiff, m);
        }
      }
    }
    return super.customAction(name, extras);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final loopMode = _player.loopMode;
    List<MediaControl> controls;
    List<MediaAction> systemActions;

    final isPodcast = _spiff.isPodcast;
    final isLive = _spiff.isLive;

    if (isPodcast) {
      controls = [
        const MediaControl(
          androidIcon: 'drawable/replay_10_24px',
          label: 'Rewind 10s',
          action: MediaAction.rewind,
        ),
        if (playing) MediaControl.pause else MediaControl.play,
        const MediaControl(
          androidIcon: 'drawable/forward_30_24px',
          label: 'Fast Forward 30s',
          action: MediaAction.fastForward,
        ),
      ];
      systemActions = const [
        MediaAction.stop,
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ];
    } else if (isLive) {
      controls = [if (playing) MediaControl.pause else MediaControl.play];
      systemActions = const [MediaAction.stop, MediaAction.seek];
    } else {
      controls = [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        _loopControl(loopMode),
      ];
      systemActions = const [
        MediaAction.skipToPrevious,
        MediaAction.skipToNext,
        MediaAction.stop,
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setRepeatMode,
      ];
    }

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: Set<MediaAction>.from(systemActions),
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
        repeatMode: _repeatMode,
      ),
    );
  }
}
