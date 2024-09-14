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

import 'package:storage_space/storage_space.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/util.dart';

import 'spiff.dart';
import 'track_repository.dart';

// TODO prune will currently delete all tracks not found in a spiff.
// podcasts can download an episode w/o a spiff
Future<void> pruneCache(
    {required SpiffCacheCubit spiffCache,
    required TrackCacheCubit trackCache,
    required SettingsCubit settings}) async {
  final spiffs = await spiffCache.repository.entries;

  await _pruneTracks(spiffs, trackCache.repository);

  await _pruneSpiffs(
    spiffs,
    settings.state.settings.cacheUsageThreshold,
    spiffCache: spiffCache,
    trackCache: trackCache,
  );
}

Future<void> _pruneSpiffs(
  Iterable<Spiff> spiffs,
  int cacheUsageThreshold, {
  required SpiffCacheCubit spiffCache,
  required TrackCacheCubit trackCache,
}) async {
  int spiffsTotal = spiffs.fold(0, (total, spiff) => spiff.size + total);

  final list = List<Spiff>.from(spiffs);
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  list.sort(
      (a, b) => (a.lastModified ?? epoch).compareTo(b.lastModified ?? epoch));

  final storage = await getStorageSpace(
      lowOnSpaceThreshold: 500 * megabyte, fractionDigits: 1);

  // walk through the oldest spiffs first and remove until the threshold is met
  //
  // keep the track cache usage to be no more than 80% of the total usage.
  // if this is exceeded, full spiffs + tracks are removed until
  // the usage drops below 80%. The actual percentage is a user setting.
  var purgeAmount = spiffsTotal - ((cacheUsageThreshold / 100) * storage.used);
  while (purgeAmount > 0 && list.isNotEmpty) {
    final spiff = list.first;

    // TODO not all tracks may be cached so the actual amount removed could be incorrect
    purgeAmount -= spiff.size;
    trackCache.removeIds(spiff.playlist.tracks);
    spiffCache.remove(spiff);

    list.removeAt(0);
  }
}

Future<void> _pruneTracks(
    Iterable<Spiff> spiffs, TrackCacheRepository trackCache) async {
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
  return trackCache.retain(keep);
}
