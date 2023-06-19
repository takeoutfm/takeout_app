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

import 'package:logging/logging.dart';
import 'package:path/path.dart';

abstract class FileIdentifier {
  String get key;
}

abstract class FileCacheProvider {
  Future<File?> get(FileIdentifier id);

  Future<bool> contains(FileIdentifier id);

  Future<void> put(FileIdentifier id, File file);

  Future<void> remove(FileIdentifier id, {bool delete = true});

  Future<void> removeAll();

  File create(FileIdentifier id);

  Future<void> retain(Iterable<FileIdentifier> ids);

  Future<Iterable<String>> keys();

  int cacheSize();
}

class DirectoryFileCache implements FileCacheProvider {
  static final log = Logger('DirectoryFileCache');

  final Directory directory;
  final Map<String, File> _entries = {};
  late Future<void> _initialized;

  DirectoryFileCache({required this.directory}) {
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
    return Future.forEach(files, (FileSystemEntity entity) async {
      // entry keys are file names
      _entries[basename(entity.path)] = entity as File;
    });
  }

  File _toFile(FileIdentifier id) {
    return File('${directory.path}/${id.key}');
  }

  @override
  Future<bool> contains(FileIdentifier id) async {
    await _initialized;
    final file = await get(id);
    return file is File && file.existsSync();
  }

  @override
  Future<File?> get(FileIdentifier id) async {
    await _initialized;
    final file = _toFile(id);
    return file.exists().then((exists) => exists ? file : null);
  }

  @override
  Future<void> put(FileIdentifier id, File file) async {
    await _initialized;
    // key should be the cleaned etag or similar hash
    _entries[id.key] = file;
  }

  // Create a file that will later be stored in the cache
  @override
  File create(FileIdentifier id) {
    return _toFile(id);
  }

  @override
  Future<void> remove(FileIdentifier id, {bool delete = true}) async {
    await _initialized;
    final file = await get(id);
    if (file != null) {
      _remove(id.key, delete: delete);
    }
  }

  void _remove(String key, {bool delete = true}) {
    final file = _entries.remove(key);
    if (delete) {
      log.fine('removing $file');
      file?.deleteSync();
    }
  }

  @override
  Future<void> removeAll() async {
    await _initialized;
    // copy keys to avoid concurrent modification
    for (final key in List<String>.from(_entries.keys)) {
      _remove(key);
    }
  }

  @override
  Future<void> retain(Iterable<FileIdentifier> keep) async {
    await _initialized;
    final removal = Set<String>.from(_entries.keys);
    for (final e in keep) {
      removal.remove(e.key);
    }
    return Future.forEach<String>(removal, (key) async {
      _remove(key, delete: true);
    });
  }

  @override
  Future<Iterable<String>> keys() async {
    await _initialized;
    return _entries.keys;
  }

  @override
  int cacheSize() {
    var size = 0;
    for (final e in _entries.values) {
      size += e.lengthSync();
    }
    return size;
  }
}
