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

import 'package:bloc/bloc.dart';
import 'package:takeout_lib/browser/repository.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/player/provider.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/tokens/repository.dart';

import 'repeat.dart';

abstract class PlayerEvent {
  final Spiff spiff;

  PlayerEvent(this.spiff);

  int get currentIndex => spiff.index >= 0 ? spiff.index : 0;

  int get lastIndex => spiff.length - 1;

  bool get isFirst => currentIndex == 0;

  bool get isLast => currentIndex == lastIndex;

  bool get hasPrevious => currentIndex != 0;

  bool get hasNext => currentIndex != lastIndex;

  MediaTrack? get currentTrack => spiff.playlist.tracks.isNotEmpty
      ? spiff.playlist.tracks[currentIndex]
      : null;
}

abstract class PlayerProcessingEvent extends PlayerEvent {
  final bool playing;
  final bool buffering;

  PlayerProcessingEvent(
    super.spiff, {
    this.playing = false,
    this.buffering = false,
  });
}

abstract class PlayerPositionEvent extends PlayerProcessingEvent {
  final Duration duration;
  final Duration position;

  PlayerPositionEvent(
    super.spiff, {
    required this.duration,
    required this.position,
    required super.playing,
    super.buffering = false,
  });

  bool get considerListened {
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

  bool get considerComplete {
    final d = duration * 0.95;
    return duration > Duration.zero && position > d;
  }

  double get progress {
    final pos = position.inSeconds.toDouble();
    return duration > Duration.zero ? pos / duration.inSeconds.toDouble() : 0.0;
  }
}

class PlayerLoad extends PlayerProcessingEvent {
  final bool autoPlay;
  final bool autoCache;

  PlayerLoad(
    super.spiff, {
    required this.autoPlay,
    required this.autoCache,
    super.buffering,
    super.playing,
  });
}

class PlayerInit extends PlayerEvent {
  PlayerInit() : super(Spiff.empty());
}

class PlayerReady extends PlayerEvent {
  PlayerReady() : super(Spiff.empty());
}

class PlayerPlay extends PlayerPositionEvent {
  PlayerPlay(
    super.spiff, {
    required super.duration,
    required super.position,
    super.playing = true,
    super.buffering = false,
  });
}

class PlayerPause extends PlayerPositionEvent {
  PlayerPause(
    super.spiff, {
    required super.duration,
    required super.position,
    super.playing = false,
    super.buffering = false,
  });
}

class PlayerStop extends PlayerEvent {
  PlayerStop(super.spiff);
}

class PlayerIndexChange extends PlayerEvent {
  final bool playing;

  PlayerIndexChange(super.spiff, this.playing);
}

class PlayerPositionChange extends PlayerPositionEvent {
  PlayerPositionChange(
    super.spiff, {
    required super.duration,
    required super.position,
    required super.playing,
  });
}

class PlayerDurationChange extends PlayerPositionEvent {
  PlayerDurationChange(
    super.spiff, {
    required super.duration,
    required super.position,
    required super.playing,
  });
}

//
// class PlayerProgressChange extends PlayerPositionState {
//   PlayerProgressChange(super.spiff,
//       {required super.duration,
//       required super.position,
//       required super.playing});
// }

class PlayerTrackListen extends PlayerPositionChange {
  PlayerTrackListen(
    super.spiff, {
    required super.duration,
    required super.position,
    required super.playing,
  });
}

class PlayerTrackChange extends PlayerEvent {
  final int index;
  final String? title;
  final String? image;

  PlayerTrackChange(super.spiff, this.index, {this.title, this.image});
}

class PlayerTrackEnd extends PlayerPositionEvent {
  final int index;

  PlayerTrackEnd(
    super.spiff,
    this.index, {
    required super.duration,
    required super.position,
    required super.playing,
  });
}

class PlayerRepeatModeChange extends PlayerEvent {
  final RepeatMode repeat;

  PlayerRepeatModeChange(super.spiff, this.repeat);
}

class PlayerStreamTrackChange extends PlayerEvent {
  final StreamTrack track;

  PlayerStreamTrackChange(super.spiff, this.track);
}

class Player extends Cubit<PlayerEvent> {
  final PlayerProvider _provider;
  final MediaTrackResolver trackResolver;
  final TokenRepository tokenRepository;
  final SettingsRepository settingsRepository;
  final OffsetCacheRepository offsetRepository;
  final MediaRepository mediaRepository;

  Player({
    required this.trackResolver,
    required this.tokenRepository,
    required this.settingsRepository,
    required this.offsetRepository,
    required this.mediaRepository,
    PositionInterval? positionInterval,
    PlayerProvider? provider,
  }) : _provider = provider ?? DefaultPlayerProvider(),
       super(PlayerInit()) {
    _provider
        .init(
          tokenRepository: tokenRepository,
          settingsRepository: settingsRepository,
          trackResolver: trackResolver,
          offsetRepository: offsetRepository,
          mediaRepository: mediaRepository,
          positionInterval: positionInterval,
          onPlay: (spiff, duration, position, buffering) => emit(
            PlayerPlay(
              spiff,
              duration: duration,
              position: position,
              buffering: buffering,
            ),
          ),
          onPause: (spiff, duration, position, buffering) => emit(
            PlayerPause(
              spiff,
              duration: duration,
              position: position,
              buffering: buffering,
            ),
          ),
          onStop: (spiff) => emit(PlayerStop(spiff)),
          onIndexChange: (spiff, playing) =>
              emit(PlayerIndexChange(spiff, playing)),
          onPositionChange: (spiff, duration, position, playing) => emit(
            PlayerPositionChange(
              spiff,
              duration: duration,
              position: position,
              playing: playing,
            ),
          ),
          onDurationChange: (spiff, duration, position, playing) => emit(
            PlayerDurationChange(
              spiff,
              duration: duration,
              position: position,
              playing: playing,
            ),
          ),
          onListen: (spiff, duration, position, playing) => emit(
            PlayerTrackListen(
              spiff,
              duration: duration,
              position: position,
              playing: playing,
            ),
          ),
          onTrackChange: (spiff, index, {String? title, String? image}) =>
              emit(PlayerTrackChange(spiff, index, title: title, image: image)),
          onTrackEnd: (spiff, index, duration, position, playing) => emit(
            PlayerTrackEnd(
              spiff,
              index,
              duration: duration,
              position: position,
              playing: playing,
            ),
          ),
          onRepeatModeChange: (spiff, repeat) =>
              emit(PlayerRepeatModeChange(spiff, repeat)),
          onStreamTrackChange: (spiff, track) =>
              emit(PlayerStreamTrackChange(spiff, track)),
        )
        .whenComplete(() => emit(PlayerReady()));
  }

  Future<void> load(
    Spiff spiff, {
    bool autoPlay = false,
    bool autoCache = false,
    RepeatMode? repeat,
  }) => _provider.load(
    spiff,
    autoCache: autoCache,
    repeat: repeat,
    onLoad: (spiff, position, playing, buffering) => emit(
      PlayerLoad(
        spiff,
        autoPlay: autoPlay,
        autoCache: autoCache,
        buffering: buffering,
        playing: playing,
      ),
    ),
  );

  Future<void> play() => _provider.play();

  Future<void> playIndex(int index) => _provider.playIndex(index);

  Future<void> pause() => _provider.pause();

  Future<void> stop() => _provider.stop();

  Future<void> seek(Duration position) => _provider.seek(position);

  Future<void> skipForward() => _provider.skipForward();

  Future<void> skipBackward() => _provider.skipBackward();

  Future<void> skipToIndex(int index) => _provider.skipToIndex(index);

  Future<void> skipToNext() => _provider.skipToNext();

  Future<void> skipToPrevious() => _provider.skipToPrevious();

  Future<void> repeatMode(RepeatMode repeat) => _provider.repeatMode(repeat);

  Future<void> dispose() => _provider.dispose();
}
