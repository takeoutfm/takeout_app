// Copyright 2026 defsub
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

import 'package:flutter/material.dart' hide Offset;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/video/player.dart';
import 'package:takeout_lib/video/source.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_lib/api/model.dart';

void playVideo(
  BuildContext context,
  VideoTrack video, {
  Duration? startOffset,
}) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) {
        final media = PlayerState(
          video: video,
          settingsRepository: context.read<SettingsRepository>(),
          tokenRepository: context.read<TokenRepository>(),
          mediaTrackResolver: context.read<MediaTrackResolver>(),
          startOffset: startOffset,
        );
        context.nowWatching.add(video, autoSubtitles: true, autoStart: true);
        return VideoPlayer.create(
          state: media,
          onPause: (position, duration) =>
              pauseVideo(context, video, position, duration),
          onAudioTrackChange: (index) =>
              context.nowWatching.setAudioTrack(index),
          onSubtitleTrackChange: (index) =>
              context.nowWatching.setSubtitleTrack(index),
        );
      },
    ),
  );
}

void pauseVideo(
  BuildContext context,
  VideoTrack video,
  Duration position,
  Duration duration,
) {
  // preserve the latest progress in now watching
  final offset = Offset.now(
    etag: video.etag,
    duration: duration,
    offset: position,
  );
  print('video setoffset $offset');
  context.nowWatching.setOffset(offset);
  context.updateProgress(video.etag, position: position, duration: duration);
}
