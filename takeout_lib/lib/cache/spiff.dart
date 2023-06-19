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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:takeout_lib/spiff/model.dart';

class SpiffCacheState {
  final Iterable<Spiff>? spiffs;

  SpiffCacheState(this.spiffs);

  factory SpiffCacheState.empty() => SpiffCacheState([]);

  bool contains(Spiff spiff) {
    return spiffs?.contains(spiff) ?? false;
  }

  int get size => spiffs?.fold<int>(0, (sum, spiff) => sum + spiff.size) ?? 0;
}

class SpiffCacheCubit extends Cubit<SpiffCacheState> {
  final SpiffCacheRepository repository;

  SpiffCacheCubit(this.repository) : super(SpiffCacheState.empty()) {
    _emitState();
  }

  Future<void> _emitState() async {
    emit(SpiffCacheState(await repository.entries));
  }

  void add(Spiff spiff) {
    repository.add(spiff).whenComplete(() => _emitState());
  }

  void remove(Spiff spiff) {
    repository.remove(spiff).whenComplete(() => _emitState());
  }

  void removeAll() {
    repository.removeAll().whenComplete(() => _emitState());
  }
}

class SpiffCacheRepository {
  final Directory directory;
  final SpiffCache _cache;

  SpiffCacheRepository({required this.directory, SpiffCache? cache})
      : _cache = cache ?? DirectorySpiffCache(directory);

  Future<void> add(Spiff spiff) async {
    return _cache.add(spiff);
  }

  Future<void> remove(Spiff spiff) async {
    return _cache.remove(spiff);
  }

  Future<void> removeAll() async {
    return _cache.removeAll();
  }

  Future<Iterable<Spiff>> get entries async => _cache.entries;
}

abstract class SpiffCache {
  Future<void> add(Spiff spiff);

  Future<Iterable<Spiff>> get entries;

  Future<void> remove(Spiff spiff);

  Future<void> removeAll();
}

class DirectorySpiffCache implements SpiffCache {
  static final log = Logger('DirectorySpiffCache');

  final Directory directory;
  final Map<String, Spiff> _cache = {};
  late Future<void> _initialized;

  DirectorySpiffCache(this.directory) {
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
      final spiff = _decode(file as File);
      if (spiff != null) {
        await _add(spiff);
      } else {
        // corrupt? delete it
        log.warning('spiff deleting $file');
        file.deleteSync();
      }
    });
  }

  Spiff? _decode(File file) {
    try {
      return Spiff.fromJson(
              jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)
          .copyWith(lastModified: file.lastModifiedSync());
    } on FormatException {
      log.warning('failed parsing $file with "${file.readAsStringSync()}"');
      return null;
    }
  }

  File _cacheFile(String key) {
    return File('${directory.path}/$key.json');
  }

  String _md5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String _cacheKey(Spiff spiff) {
    return _md5('${spiff.title}${spiff.location}${spiff.date}');
  }

  Future<File?> _save(String key, Spiff spiff) async {
    final data = jsonEncode(spiff.toJson());
    try {
      File file = _cacheFile(key);
      await file.writeAsString(data);
      return file;
    } catch (e) {
      log.warning(e);
      return Future.error(e);
    }
  }

  @override
  Future<void> add(Spiff spiff) async {
    await _initialized;
    return _add(spiff);
  }

  Future<void> _add(Spiff spiff) async {
    final key = _cacheKey(spiff);
    final curr = _cache[key];
    if (curr != null &&
        spiff == curr &&
        spiff.index == curr.index &&
        spiff.position == curr.position) {
      // log.fine('put unchanged');
      return;
    } else {
      final file = await _save(key, spiff);
      if (file != null) {
        _cache[key] = spiff;
      }
    }
  }

  @override
  Future<Iterable<Spiff>> get entries async {
    await _initialized;
    return List.unmodifiable(_cache.values);
  }

  @override
  Future<void> remove(Spiff spiff) async {
    await _initialized;
    final key = _cacheKey(spiff);
    _cache.remove(key);
    try {
      _cacheFile(key).deleteSync();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<void> removeAll() async {
    await _initialized;
    // copy list to avoid concurrent modification
    final values = List<Spiff>.from(_cache.values);
    return Future.forEach<Spiff>(values, (spiff) async => remove(spiff));
  }
}
