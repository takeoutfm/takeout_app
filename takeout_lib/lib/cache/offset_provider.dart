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

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:takeout_lib/api/model.dart';

import 'offset_repository.dart';

extension FileExpiration on File {
  bool isExpired(Duration ttl) {
    final expirationTime = lastModifiedSync().add(ttl);
    return DateTime.now().isAfter(expirationTime);
  }
}

abstract class OffsetCache {
  Future<Offset?> get(OffsetIdentifier id, {Duration? ttl});

  Future<bool> contains(Offset offset);

  Future<void> put(Offset offset);

  Future<void> remove(Offset offset);

  Future<Iterable<Offset>> merge(Iterable<Offset> offsets);

  Future<Map<String, Offset>> get entries;
}

class OffsetFileCache implements OffsetCache {
  static final log = Logger('OffsetFileCache');

  final Directory directory;
  final Map<String, Offset> _entries = {};
  late Future<void> _initialized;

  OffsetFileCache({required this.directory}) {
    try {
      if (directory.existsSync() == false) {
        directory.createSync(recursive: true);
      }
    } catch (e, stack) {
      log.warning(directory, e, stack);
    }
    _initialized = _initialize();
  }

  Future<void> _initialize() async {
    final files = await directory.list().toList();
    return Future.forEach<FileSystemEntity>(files, (file) async {
      final offset = _decode(file as File);
      if (offset != null) {
        await _put(offset);
      } else {
        // corrupt? delete it
        log.warning('offset deleting $file');
        file.deleteSync();
      }
    });
  }

  File _cacheFile(String key) {
    // ensure no weird chars
    var fileName = key.replaceAll(RegExp(r'[^a-zA-Z\d_-]'), '_');
    fileName = '$fileName.json';
    return File('${directory.path}/$fileName');
  }

  Offset? _decode(File file) {
    try {
      return Offset.fromJson(jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
    } on FormatException {
      log.warning(
          '_decode failed to parse $file with "${file.readAsStringSync()}"');
      return null;
    }
  }

  Future<File> _save(Offset offset) async {
    File file = _cacheFile(offset.etag);
    log.fine('saving ${offset.etag} ${offset.position()} ${offset.duration} to $file');
    final data = jsonEncode(offset.toJson());
    return file.writeAsString(data);
  }

  @override
  Future<bool> contains(Offset offset) async {
    await _initialized;
    final current = await _get(offset.etag);
    return current != null && offset == current;
  }

  @override
  Future<Offset?> get(OffsetIdentifier id, {Duration? ttl}) async {
    await _initialized;
    return _get(id.etag, ttl: ttl);
  }

  Future<Offset?> _get(String key, {Duration? ttl}) async {
    if (_entries.containsKey(key) == false) {
      return null;
    }
    if (ttl != null) {
      final file = _cacheFile(key);
      return file.exists().then((exists) {
        if (exists) {
          if (file.isExpired(ttl)) {
            log.fine('deleting expired offset $file');
            _remove(key);
          } else {
            return _entries[key];
          }
        }
        return null;
      });
    } else {
      return _entries[key];
    }
  }

  @override
  Future<void> put(Offset offset) async {
    await _initialized;
    await _put(offset).then((value) => _save(offset));
  }

  Future<Offset> _put(Offset offset) async {
    final curr = _entries[offset.etag];
    if (curr != null && curr.hasDuration() && offset.duration == 0) {
      // duration is dynamic so don't zero out previously found duration
      offset = offset.copyWith(duration: curr.duration);
    }
    _entries[offset.etag] = offset;
    return offset;
  }

  @override
  Future<Iterable<Offset>> merge(Iterable<Offset> offsets) async {
    await _initialized;
    final newer = <Offset>[];
    await Future.forEach<Offset>(offsets, (remote) async {
      final local = await get(remote);
      if (local != null && local.newerThan(remote)) {
        newer.add(local);
      } else if (await contains(remote) == false) {
        await put(remote);
      }
    });
    return newer;
  }

  @override
  Future<void> remove(Offset offset) async {
    await _initialized;
    _remove(offset.etag);
  }

  void _remove(String key) {
    _entries.remove(key);
    final file = _cacheFile(key);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  void removeAll() async {
    await _initialized;
    for (var key in _entries.keys) {
      _remove(key);
    }
  }

  @override
  Future<Map<String, Offset>> get entries async {
    await _initialized;
    return Map.unmodifiable(_entries);
  }
}
