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
