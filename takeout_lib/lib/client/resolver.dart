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

import 'package:takeout_lib/cache/track_repository.dart';
import 'package:takeout_lib/model.dart';

import 'etag.dart';

class MediaTrackResolver {
  final TrackUriResolver _resolver;
  final TrackCacheRepository trackCacheRepository;

  MediaTrackResolver(
      {required this.trackCacheRepository, TrackUriResolver? resolver})
      : _resolver = resolver ?? DefaultTrackResolver(trackCacheRepository);

  Future<Uri> resolve(MediaTrack track) async {
    return _resolver.resolve(track);
  }
}

class _TrackIdentifier implements TrackIdentifier {
  final ETag _etag;

  _TrackIdentifier(MediaTrack track) : _etag = ETag(track.etag);

  @override
  String get key => _etag.key;
}

abstract class TrackUriResolver {
  Future<Uri> resolve(MediaTrack track);
}

class DefaultTrackResolver implements TrackUriResolver {
  final TrackCacheRepository trackCacheRepository;

  DefaultTrackResolver(this.trackCacheRepository);

  /// Return uri from track cache or remote track uri.
  @override
  Future<Uri> resolve(MediaTrack track) async {
    final id = _TrackIdentifier(track);
    final file = await trackCacheRepository.get(id);
    return (file != null) ? file.uri : Uri.parse(track.location);
  }
}
