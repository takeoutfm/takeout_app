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
import 'package:media_kit/media_kit.dart';

class TrackSelection extends StatelessWidget {
  final Player player;

  const TrackSelection(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    final video = <Widget>[];
    for (final t in player.state.tracks.video) {
      if (t.id == 'auto' || t.id == 'no') {
        video.add(
          RadioListTile<VideoTrack>(
            dense: true,
            value: t,
            title: Text(t.id == 'no' ? 'none' : 'auto'),
          ),
        );
      } else {
        video.add(
          RadioListTile<VideoTrack>(
            dense: true,
            value: t,
            title: Text('${t.codec}'),
          ),
        );
      }
    }
    final videoSelection = StreamBuilder<VideoTrack>(
      initialData: player.state.track.video,
      stream: player.stream.track.map((t) => t.video),
      builder: (context, snapshot) {
        final selected = snapshot.data;
        return RadioGroup<VideoTrack>(
          groupValue: selected,
          onChanged: (track) {
            if (track != null) {
              player.setVideoTrack(track);
              // Navigator.of(context).pop();
            }
          },
          child: Column(
            crossAxisAlignment: .center,
            children: [Text('Video'), ...video],
          ),
        );
      },
    );

    final subtitles = <Widget>[];
    for (final t in player.state.tracks.subtitle) {
      if (t.id == 'auto' || t.id == 'no') {
        subtitles.add(
          RadioListTile<SubtitleTrack>(
            dense: true,
            value: t,
            title: Text(t.id == 'no' ? 'none' : 'auto'),
          ),
        );
      } else {
        subtitles.add(
          RadioListTile<SubtitleTrack>(
            dense: true,
            value: t,
            title: Text('${t.language}'),
          ),
        );
      }
    }
    final subtitleSelection = StreamBuilder<SubtitleTrack>(
      initialData: player.state.track.subtitle,
      stream: player.stream.track.map((t) => t.subtitle),
      builder: (context, snapshot) {
        final selected = snapshot.data;
        return RadioGroup<SubtitleTrack>(
          groupValue: selected,
          onChanged: (track) {
            if (track != null) {
              player.setSubtitleTrack(track);
              // Navigator.of(context).pop();
            }
          },
          child: Column(
            crossAxisAlignment: .center,
            children: [Text('Subtitles'), ...subtitles],
          ),
        );
      },
    );

    final audio = <Widget>[];
    for (final t in player.state.tracks.audio) {
      final channels = switch (t.audiochannels) {
        1 => 'Mono',
        2 => 'Stereo',
        6 => 'Surround 5.1',
        7 => 'Surround 5.2',
        8 => 'Surround 7.1',
        _ => '${t.audiochannels}',
      };
      final codec = switch (t.codec) {
        'truehd' => 'True HD',
        'dts-hd' => 'DTS HD',
        _ => t.codec?.toUpperCase(),
      };
      if (t.id == 'auto' || t.id == 'no') {
        audio.add(
          RadioListTile<AudioTrack>(
            dense: true,
            value: t,
            title: Text(t.id == 'no' ? 'none' : 'auto'),
          ),
        );
      } else {
        audio.add(
          RadioListTile<AudioTrack>(
            dense: true,
            value: t,
            title: Text('$codec - $channels'),
            subtitle: Text('${t.language}'),
          ),
        );
      }
    }
    final audioSelection = StreamBuilder<AudioTrack>(
      initialData: player.state.track.audio,
      stream: player.stream.track.map((t) => t.audio),
      builder: (context, snapshot) {
        final selected = snapshot.data;
        return RadioGroup<AudioTrack>(
          groupValue: selected,
          onChanged: (track) {
            if (track != null) {
              player.setAudioTrack(track);
              // Navigator.of(context).pop();
            }
          },
          child: Column(children: [Text('Audio'), ...audio]),
        );
      },
    );

    return Row(
      // mainAxisAlignment: .start,
      crossAxisAlignment: .start,
      children: [
        Expanded(child: videoSelection),
        Expanded(child: subtitleSelection),
        Expanded(child: audioSelection),
      ],
    );
  }
}
