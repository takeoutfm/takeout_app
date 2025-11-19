// Copyright 2025 defsub
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

import 'dart:async';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart';
import 'package:takeout_lib/api/client.dart';
import 'package:takeout_lib/connectivity/provider.dart';
import 'package:takeout_lib/connectivity/repository.dart';
import 'package:takeout_lib/model.dart';

import 'model.dart';
import 'provider.dart';

class RetryListenProvider implements ListenProvider {
  static final log = Logger();

  final String name;
  final String _boxName;
  final ConnectivityRepository connectivityRepository;
  final ListenProvider listenProvider;
  late Box<Listen> box;

  RetryListenProvider(
    this.name,
    this.listenProvider,
    this.connectivityRepository,
  ) : _boxName = 'listens_$name' {
    _init();
  }

  void _init() async {
    // Note: Hive init and register adapters is called in main
    box = await Hive.openBox<Listen>(_boxName);

    connectivityRepository
        .streamWithTimeout(timeout: const Duration(minutes: 5))
        .skipWhile((type) => type == ConnectivityType.none)
        .listen((_) => _processQueue());
  }

  Future<void> _processQueue() async {
    int count = 0;
    if (box.isNotEmpty) {
      log.d('listen queue: ${box.length}');
    }
    for (final listen in box.values) {
      if (count > 0) {
        // delay between retries
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      await listen.delete();
      try {
        await _retry(listen, listen.listenedAt);
      } catch (e, stackTrace) {
        log.w('retry failed', error: e, stackTrace: stackTrace);
      }
      count++;
    }
  }

  Future<void> _enqueue(MediaTrack track, DateTime listenedAt) {
    return box.put(
      listenedAt.toString(),
      Listen.fromMediaTrack(track, listenedAt),
    );
  }

  Future<void> _retry(MediaTrack track, DateTime listenedAt) {
    return listened(track, listenedAt);
  }

  @override
  Future<void> playingNow(MediaTrack track) {
    return listenProvider.playingNow(track);
  }

  @override
  Future<void> listened(MediaTrack track, DateTime listenedAt) async {
    try {
      // first try to submit the listen
      await listenProvider.listened(track, listenedAt);
    } on Exception catch (e) {
      if (_shouldRetry(e)) {
        // will retry with network errors or timeouts
        await _enqueue(track, listenedAt);
      } else {
        // some other error, don't retry
        rethrow;
      }
    }
  }

  bool _shouldRetry(Exception e) {
    if (e is SocketException || e is TimeoutException || e is TlsException) {
      // network error
      return true;
    }
    if (e is ClientException) {
      // server issue
      return e.statusCode >= 500;
    }
    return false;
  }
}
