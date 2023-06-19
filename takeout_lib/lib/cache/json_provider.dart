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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';

import 'json_repository.dart';

abstract class JsonCacheProvider {
  Future<bool> put(String uri, Uint8List body);

  Future<JsonCacheResult> get(String uri, {Duration? ttl});
}

class JsonCacheEntry extends JsonCacheResult {
  final String uri;
  final File file;
  final DateTime lastModified;

  JsonCacheEntry(this.uri, this.file, this.lastModified, bool expired)
      : super(true, expired);

  @override
  Future<Map<String, dynamic>> read() async {
    try {
      return await file
          .readAsBytes()
          .then((body) => jsonDecode(utf8.decode(body)) as Map<String, dynamic>);
    } catch (e) {
      return Future.error(e);
    }
  }
}

class DirectoryJsonCache implements JsonCacheProvider {
  static final log = Logger('JsonCache');

  final Directory directory;

  DirectoryJsonCache(this.directory) {
    try {
      if (directory.existsSync() == false) {
        directory.createSync(recursive: true);
      }
    } catch (e, stack) {
      log.warning(directory, e, stack);
    }
  }

  String _md5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  File _jsonFile(String uri) {
    final key = _md5(uri);
    final path = '${directory.path}/$key.json';
    return File(path);
  }

  @override
  Future<bool> put(String uri, Uint8List body) async {
    var success = true;
    final file = _jsonFile(uri);
    try {
      await file.writeAsBytes(body);
    } catch (e) {
      log.warning(e);
      success = false;
    }
    return success;
  }

  @override
  Future<JsonCacheResult> get(String uri, {Duration? ttl}) async {
    final file = _jsonFile(uri);
    return file.exists().then((exists) {
      if (exists) {
        final lastModified = file.lastModifiedSync();
        if (ttl != null) {
          final expirationTime = lastModified.add(ttl);
          final expired = DateTime.now().isAfter(expirationTime);
          return JsonCacheEntry(uri, file, lastModified, expired);
        } else {
          return JsonCacheEntry(uri, file, lastModified, false);
        }
      } else {
        return JsonCacheResult.notFound();
      }
    });
  }
}
