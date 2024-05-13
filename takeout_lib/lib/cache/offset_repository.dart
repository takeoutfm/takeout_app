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

import 'dart:io';

import 'package:takeout_lib/api/model.dart';

import 'offset_provider.dart';

abstract class OffsetIdentifier {
  String get etag;
}

class OffsetCacheRepository {
  final Directory directory;
  final OffsetCache _cache;

  OffsetCacheRepository({required this.directory, OffsetCache? cache})
      : _cache = cache ?? OffsetFileCache(directory: directory);

  Future<Offset?> get(OffsetIdentifier id, {Duration? ttl}) async {
    return _cache.get(id, ttl: ttl);
  }

  Future<bool> contains(Offset offset) async {
    return _cache.contains(offset);
  }

  Future<void> put(Offset offset) async {
    return _cache.put(offset);
  }

  Future<void> remove(Offset offset) {
    return _cache.remove(offset);
  }

  Future<Iterable<Offset>> merge(Iterable<Offset> offsets) {
    return _cache.merge(offsets);
  }

  Future<Map<String, Offset>> get entries async {
    return _cache.entries;
  }
}
