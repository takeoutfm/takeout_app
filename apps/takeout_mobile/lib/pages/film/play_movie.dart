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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/video/player.dart';

void playMovie(
  BuildContext context,
  MediaTrack movie, {
  Duration? startOffset,
}) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => VideoPlayer(
        movie,
        settingsRepository: context.read<SettingsRepository>(),
        tokenRepository: context.read<TokenRepository>(),
        mediaTrackResolver: context.read<MediaTrackResolver>(),
        startOffset: startOffset,
        onPause: (position, duration) =>
            pauseMovie(context, movie, position, duration),
      ),
    ),
  );
}

void pauseMovie(
  BuildContext context,
  MediaTrack movie,
  Duration position,
  Duration duration,
) {
  context.updateProgress(movie.etag, position: position, duration: duration);
}
