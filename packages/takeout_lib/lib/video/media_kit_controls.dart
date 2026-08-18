import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:takeout_lib/util.dart';

Widget withControls(BuildContext context, Video video) {
  return MaterialVideoControlsTheme(
    normal: MaterialVideoControlsThemeData(
      topButtonBar: [
        MaterialCustomButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        const Spacer(),
        MaterialCustomButton(
          onPressed: () => showAudioMenu(context, video.controller),
          icon: const Icon(Icons.speaker),
        ),
        MaterialCustomButton(
          onPressed: () => showSubtitleMenu(context, video.controller),
          icon: const Icon(Icons.subtitles),
        ),
      ],
    ),
    fullscreen: MaterialVideoControlsThemeData(
      topButtonBar: [
        MaterialCustomButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        const Spacer(),
        MaterialCustomButton(
          onPressed: () => showAudioMenu(context, video.controller),
          icon: const Icon(Icons.speaker),
        ),
        MaterialCustomButton(
          onPressed: () => showSubtitleMenu(context, video.controller),
          icon: const Icon(Icons.subtitles),
        ),
      ],
    ),
    child: MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        topButtonBar: [
          MaterialDesktopCustomButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          MaterialCustomButton(
            onPressed: () => showAudioMenu(context, video.controller),
            icon: const Icon(Icons.speaker),
          ),
          MaterialCustomButton(
            onPressed: () => showSubtitleMenu(context, video.controller),
            icon: const Icon(Icons.subtitles),
          ),
        ],
      ),
      fullscreen: const MaterialDesktopVideoControlsThemeData(),
      child: video,
    ),
  );
}

Future<void> showSubtitleMenu(
  BuildContext context,
  VideoController controller,
) async {
  final tracks = controller.player.state.tracks.subtitle;
  final current = controller.player.state.track.subtitle;

  final selected = await showMenu<SubtitleTrack>(
    context: context,
    position: const RelativeRect.fromLTRB(100, 100, 0, 0),
    items: [
      ...tracks.map(
        (track) => CheckedPopupMenuItem(
          value: track,
          checked: track.id == current.id,
          child: Text(_subtitleTrackTitle(track)),
        ),
      ),
    ],
  );

  if (selected != null) {
    await controller.player.setSubtitleTrack(selected);
  }
}

Future<void> showAudioMenu(
  BuildContext context,
  VideoController controller,
) async {
  final tracks = controller.player.state.tracks.audio;
  final current = controller.player.state.track.audio;

  final selected = await showMenu<AudioTrack>(
    context: context,
    position: const RelativeRect.fromLTRB(100, 100, 0, 0),
    items: [
      ...tracks.map(
        (track) => CheckedPopupMenuItem(
          value: track,
          checked: track.id == current.id,
          child: Text(_audioTrackTitle(track)),
        ),
      ),
    ],
  );

  if (selected != null) {
    await controller.player.setAudioTrack(selected);
  }
}

String _subtitleTrackTitle(SubtitleTrack track) {
  if (track.id == 'auto') {
    return 'Auto';
  } else if (track.id == 'no') {
    return 'None';
  } else {
    return track.language?.titleCased ?? 'na';
  }
}

String _audioTrackTitle(AudioTrack track) {
  final channels = switch (track.audiochannels) {
    1 => 'Mono',
    2 => 'Stereo',
    6 => 'Surround 5.1',
    7 => 'Surround 5.2',
    8 => 'Surround 7.1',
    _ => '${track.audiochannels}',
  };
  final codec = switch (track.codec) {
    'truehd' => 'True HD',
    'dts-hd' => 'DTS HD',
    _ => track.codec?.toUpperCase(),
  };
  if (track.id == 'auto') {
    return 'Auto';
  } else if (track.id == 'no') {
    return 'None';
  } else {
    return '$codec - $channels (${track.language?.titleCased})';
  }
}
