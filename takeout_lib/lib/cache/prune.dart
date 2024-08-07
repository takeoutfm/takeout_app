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

import 'package:takeout_lib/spiff/model.dart';

import 'spiff.dart';
import 'track_repository.dart';

// TODO prune will currently delete all tracks not found in a spiff.
// podcasts can download an episode w/o a spiff
Future<void> pruneCache(
    SpiffCacheRepository spiffCache, TrackCacheRepository trackCache) async {
  final spiffs = await spiffCache.entries;
  final keep = <TrackIdentifier>[];
  await Future.forEach<Spiff>(spiffs, (spiff) async {
    final tracks = spiff.playlist.tracks;
    await Future.forEach<Entry>(tracks, (track) async {
      final id = track as TrackIdentifier;
      final file = await trackCache.get(id);
      if (file != null) {
        final fileSize = file.lengthSync();
        if (fileSize == track.size) {
          keep.add(id);
        } else if (spiff.isPodcast()) {
          // Allow podcasts download to be larger - TWiT sizes can be off
          // TODO is this still valid?
          if (fileSize > track.size) {
            keep.add(id);
          }
        }
        // otherwise remove likely incomplete download
      }
    });
  });
  await trackCache.retain(keep);
}
