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

import 'package:takeout_lib/browser/repository.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/tokens/repository.dart';

import 'handler.dart';

final dummyPlayCallback = (_, __, ___, ____) {};
final dummyPauseCallback = (_, __, ___, ____) {};
final dummyStoppedCallback = (_) {};
final dummyTrackChangeCallback = (_, __, {String? title}) {};
final dummyPositionCallback = (_, __, ___, ____) {};
final dummyProgressCallback = (_, __, ___, ____) {};
final dummyIndexCallback = (_, __) {};
final dummyTrackEndCallback = (_, __, ___, ____, _____) {};

typedef LoadCallback = void Function(Spiff, Duration, bool, bool);
typedef PlayCallback = void Function(Spiff, Duration, Duration, bool);
typedef PauseCallback = void Function(Spiff, Duration, Duration, bool);
typedef IndexCallback = void Function(Spiff, bool);
typedef PositionCallback = void Function(Spiff, Duration, Duration, bool);
typedef ProgressCallback = void Function(Spiff, Duration, Duration, bool);
typedef StoppedCallback = void Function(Spiff);
typedef TrackChangeCallback = void Function(Spiff, int index, {String? title});
typedef TrackEndCallback = void Function(
    Spiff, int index, Duration, Duration, bool);

class PositionInterval {
  final int steps;
  final Duration minPeriod;
  final Duration maxPeriod;

  /// from just_audio:
  /// The stream will aim to emit [steps] position updates from the
  /// beginning to the end of the current audio source, at intervals of
  /// [duration] / [steps]. This interval will be clipped between [minPeriod]
  /// and [maxPeriod]. This stream will not emit values while audio playback is
  /// paused or stalled.
  PositionInterval(
      {required this.steps, required this.minPeriod, required this.maxPeriod});
}

abstract class PlayerProvider {
  Future<void> init(
      {required MediaTrackResolver trackResolver,
      required TokenRepository tokenRepository,
      required SettingsRepository settingsRepository,
      required OffsetCacheRepository offsetRepository,
      required MediaRepository mediaRepository,
      PositionInterval? positionInterval,
      PlayCallback? onPlay,
      PauseCallback? onPause,
      StoppedCallback? onStop,
      IndexCallback? onIndexChange,
      PositionCallback? onPositionChange,
      PositionCallback? onDurationChange,
      ProgressCallback? onProgressChange,
      TrackChangeCallback? onTrackChange,
      TrackEndCallback? onTrackEnd});

  void load(Spiff spiff, {LoadCallback? onLoad});

  void play();

  void playIndex(int index);

  void pause();

  void stop();

  void seek(Duration position);

  void skipForward();

  void skipBackward();

  void skipToIndex(int index);

  void skipToNext();

  void skipToPrevious();
}

class DefaultPlayerProvider implements PlayerProvider {
  late final TakeoutPlayerHandler handler;

  @override
  Future<void> init(
      {required MediaTrackResolver trackResolver,
      required TokenRepository tokenRepository,
      required SettingsRepository settingsRepository,
      required OffsetCacheRepository offsetRepository,
      required MediaRepository mediaRepository,
      PositionInterval? positionInterval,
      PlayCallback? onPlay,
      PauseCallback? onPause,
      StoppedCallback? onStop,
      IndexCallback? onIndexChange,
      PositionCallback? onPositionChange,
      PositionCallback? onDurationChange,
      ProgressCallback? onProgressChange,
      TrackChangeCallback? onTrackChange,
      TrackEndCallback? onTrackEnd}) async {
    handler = await TakeoutPlayerHandler.create(
        trackResolver: trackResolver,
        tokenRepository: tokenRepository,
        settingsRepository: settingsRepository,
        offsetRepository: offsetRepository,
        mediaRepository: mediaRepository,
        positionSteps: positionInterval?.steps,
        minPositionPeriod: positionInterval?.minPeriod,
        maxPositionPeriod: positionInterval?.maxPeriod,
        onPlay: onPlay ?? dummyPlayCallback,
        onPause: onPause ?? dummyPauseCallback,
        onStop: onStop ?? dummyStoppedCallback,
        onIndexChange: onIndexChange ?? dummyIndexCallback,
        onPositionChange: onPositionChange ?? dummyPositionCallback,
        onDurationChange: onDurationChange ?? dummyPositionCallback,
        onProgressChange: onProgressChange ?? dummyProgressCallback,
        onTrackChange: onTrackChange ?? dummyTrackChangeCallback,
        onTrackEnd: onTrackEnd ?? dummyTrackEndCallback);
  }

  @override
  void load(Spiff spiff, {LoadCallback? onLoad}) {
    handler.load(spiff, onLoad: onLoad);
  }

  @override
  void play() => handler.play();

  @override
  void playIndex(int index) => handler.playIndex(index);

  @override
  void pause() => handler.pause();

  @override
  void stop() => handler.stop();

  @override
  void seek(Duration position) => handler.seek(position);

  @override
  void skipForward() => handler.fastForward();

  @override
  void skipBackward() => handler.rewind();

  @override
  void skipToIndex(int index) => handler.skipToQueueItem(index);

  @override
  void skipToNext() => handler.skipToNext();

  @override
  void skipToPrevious() => handler.skipToPrevious();
}
