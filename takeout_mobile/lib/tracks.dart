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

import 'package:flutter/material.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/spiff/model.dart';

import 'tiles.dart';

class TrackListWidget extends StatelessWidget {
  final List<MediaTrack> _tracks;

  const TrackListWidget(this._tracks, {super.key});

  void _onPlay(BuildContext context, int index) {
    final spiff = Spiff.fromMediaTracks(_tracks);
    context.play(spiff);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._tracks.asMap().keys.toList().map((index) =>
          CoverTrackListTile.mediaTrack(context, _tracks[index],
              onTap: () => _onPlay(context, index),
              trailing: const Icon(Icons.play_arrow)))
    ]);
  }
}
