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

import 'package:bloc/bloc.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/player/provider.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/browser/repository.dart';

abstract class PlayerState {
  final Spiff spiff;

  PlayerState(this.spiff);

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

abstract class PlayerProcessingState extends PlayerState {
  final bool playing;
  final bool buffering;

  PlayerProcessingState(super.spiff,
      {this.playing = false, this.buffering = false});
}

abstract class PlayerPositionState extends PlayerProcessingState {
  final Duration duration;
  final Duration position;

  PlayerPositionState(super.spiff,
      {required this.duration,
      required this.position,
      required super.playing,
      super.buffering = false});

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

class PlayerLoad extends PlayerProcessingState {
  final bool autoplay;

  PlayerLoad(super.spiff, this.autoplay, {super.buffering, super.playing});
}

class PlayerInit extends PlayerState {
  PlayerInit() : super(Spiff.empty());
}

class PlayerReady extends PlayerState {
  PlayerReady() : super(Spiff.empty());
}

class PlayerPlay extends PlayerPositionState {
  PlayerPlay(super.spiff,
      {required super.duration,
      required super.position,
      super.playing = true,
      super.buffering = false});
}

class PlayerPause extends PlayerPositionState {
  PlayerPause(super.spiff,
      {required super.duration,
      required super.position,
      super.playing = false,
      super.buffering = false});
}

class PlayerStop extends PlayerState {
  PlayerStop(super.spiff);
}

class PlayerIndexChange extends PlayerState {
  final bool playing;

  PlayerIndexChange(super.spiff, this.playing);
}

class PlayerPositionChange extends PlayerPositionState {
  PlayerPositionChange(super.spiff,
      {required super.duration,
      required super.position,
      required super.playing});
}

class PlayerDurationChange extends PlayerPositionState {
  PlayerDurationChange(super.spiff,
      {required super.duration,
      required super.position,
      required super.playing});
}
//
// class PlayerProgressChange extends PlayerPositionState {
//   PlayerProgressChange(super.spiff,
//       {required super.duration,
//       required super.position,
//       required super.playing});
// }

class PlayerTrackListen extends PlayerPositionChange {
  PlayerTrackListen(super.spiff,
      {required super.duration,
      required super.position,
      required super.playing});
}

class PlayerTrackChange extends PlayerState {
  final int index;
  final String? title;

  PlayerTrackChange(super.spiff, this.index, {this.title});
}

class PlayerTrackEnd extends PlayerPositionState {
  final int index;

  PlayerTrackEnd(super.spiff, this.index,
      {required super.duration,
      required super.position,
      required super.playing});
}

class Player extends Cubit<PlayerState> {
  final PlayerProvider _provider;
  final MediaTrackResolver trackResolver;
  final TokenRepository tokenRepository;
  final SettingsRepository settingsRepository;
  final OffsetCacheRepository offsetRepository;
  final MediaRepository mediaRepository;

  Player(
      {required this.trackResolver,
      required this.tokenRepository,
      required this.settingsRepository,
      required this.offsetRepository,
      required this.mediaRepository,
      PositionInterval? positionInterval,
      PlayerProvider? provider})
      : _provider = provider ?? DefaultPlayerProvider(),
        super(PlayerInit()) {
    _provider
        .init(
            tokenRepository: tokenRepository,
            settingsRepository: settingsRepository,
            trackResolver: trackResolver,
            offsetRepository: offsetRepository,
            mediaRepository: mediaRepository,
            positionInterval: positionInterval,
            onPlay: (spiff, duration, position, buffering) => emit(PlayerPlay(
                  spiff,
                  duration: duration,
                  position: position,
                  buffering: buffering,
                )),
            onPause: (spiff, duration, position, buffering) => emit(PlayerPause(
                  spiff,
                  duration: duration,
                  position: position,
                  buffering: buffering,
                )),
            onStop: (spiff) => emit(PlayerStop(spiff)),
            onIndexChange: (spiff, playing) =>
                emit(PlayerIndexChange(spiff, playing)),
            onPositionChange: (spiff, duration, position, playing) => emit(
                PlayerPositionChange(spiff,
                    duration: duration, position: position, playing: playing)),
            onDurationChange: (spiff, duration, position, playing) => emit(
                PlayerDurationChange(spiff,
                    duration: duration, position: position, playing: playing)),
            onListen: (spiff, duration, position, playing) => emit(PlayerTrackListen(spiff,
                duration: duration, position: position, playing: playing)),
            onTrackChange: (spiff, index, {String? title}) =>
                emit(PlayerTrackChange(spiff, index, title: title)),
            onTrackEnd: (spiff, index, duration, position, playing) => emit(
                PlayerTrackEnd(spiff, index,
                    duration: duration, position: position, playing: playing)))
        .whenComplete(() => emit(PlayerReady()));
  }

  void load(Spiff spiff, {bool autoplay = false}) {
    _provider.load(spiff,
        onLoad: (spiff, position, playing, buffering) => emit(PlayerLoad(
            spiff, autoplay,
            buffering: buffering, playing: playing)));
  }

  void play() => _provider.play();

  void playIndex(int index) => _provider.playIndex(index);

  void pause() => _provider.pause();

  void stop() => _provider.stop();

  void seek(Duration position) => _provider.seek(position);

  void skipForward() => _provider.skipForward();

  void skipBackward() => _provider.skipBackward();

  void skipToIndex(int index) => _provider.skipToIndex(index);

  void skipToNext() => _provider.skipToNext();

  void skipToPrevious() => _provider.skipToPrevious();
}
