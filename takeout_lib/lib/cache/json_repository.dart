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

import 'dart:io';
import 'dart:typed_data';

import 'json_provider.dart';

class JsonCacheResult {
  final bool exists;
  final bool expired;

  JsonCacheResult(this.exists, this.expired);

  factory JsonCacheResult.notFound() => JsonCacheResult(false, false);

  Future<Map<String, dynamic>> read() async {
    throw UnimplementedError;
  }
}

class JsonCacheRepository {
  final Directory directory;
  final JsonCacheProvider _cache;

  JsonCacheRepository({required this.directory, JsonCacheProvider? cache})
      : _cache = cache ?? DirectoryJsonCache(directory);

  Future<bool> put(String uri, Uint8List body) {
    return _cache.put(uri, body);
  }

  Future<JsonCacheResult> get(String uri, {Duration? ttl}) async {
    return _cache.get(uri, ttl: ttl);
  }
}
