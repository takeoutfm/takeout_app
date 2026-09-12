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

import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/video/track.dart';

import 'model.dart';

abstract class HistoryProvider {
  Future<History> add({
    String? search,
    Spiff? spiff,
    MediaTrack? track,
    LiveTrack? liveTrack,
    VideoTrack? video,
    Offset? offset,
    DateTime? dateTime,
  });

  Future<History> get();

  Future<History> remove();
}

class JsonHistoryProvider implements HistoryProvider {
  final Directory directory;
  final File _file;
  History? _history;

  JsonHistoryProvider(this.directory)
    : _file = File('${directory.path}/history.json');

  @override
  Future<History> add({
    String? search,
    Spiff? spiff,
    MediaTrack? track,
    LiveTrack? liveTrack,
    VideoTrack? video,
    Offset? offset,
    DateTime? dateTime,
  }) async {
    dateTime ??= DateTime.now();
    final history = await _checkLoaded();
    if (search != null) {
      // append search or merge duplicate
      final entry = SearchHistory(search, dateTime);
      if (history.searches.isNotEmpty &&
          history.searches.last.compareTo(entry) == 0) {
        history.searches.removeLast();
      }
      history.searches.add(entry);
    }
    if (spiff != null) {
      final last = history.lastSpiff;
      if (last != null && last.spiff == spiff) {
        // update last entry with new index (or position, etc.)
        final entry = last.copyWith(spiff: spiff);
        history.spiffs.last = entry;
      } else {
        // add history entry
        final entry = SpiffHistory(spiff, dateTime);
        history.spiffs.add(entry);
      }
    }
    if (track != null) {
      // maintain map of unique tracks by etag with play counts
      final entry = history.tracks[track.etag];
      history.tracks[track.etag] = entry == null
          ? TrackHistory.from(track, dateTime: dateTime)
          : entry.increment(1, dateTime: dateTime);
    }
    if (liveTrack != null) {
      final last = history.lastStreamHistory;
      if (last != null &&
          last.name == liveTrack.name &&
          last.title == liveTrack.title) {
        final entry = last.copyWith(dateTime);
        history.stream.last = entry;
        history.stream.first;
        history.stream.last;
      } else {
        final entry = StreamHistory.from(liveTrack, dateTime: dateTime);
        history.stream.add(entry);
      }
    }
    if (video != null) {
      final latest = history.latestVideo;
      print('video latest is ${latest?.title} ${latest?.video.etag} ${offset}');
      if (latest != null && video.etag == latest.video.etag) {
        // updated latest movie with new offset as needed
        final entry = latest.copyWith(offset: offset, dateTime: dateTime);
        history.videos.last = entry;
      } else {
        final entry = VideoHistory.from(
          video,
          offset: offset,
          dateTime: dateTime,
        );
        print('adding new entry $entry');
        history.videos.add(entry);
      }
    }
    _prune(history);
    await _save(_file, history);
    return history;
  }

  @override
  Future<History> get() async {
    return _checkLoaded();
  }

  Future<History> _checkLoaded() async {
    _history ??= await _load(_file);
    return Future.value(_history);
  }

  Future<History> _load(File file) async {
    if (file.existsSync() == false || file.lengthSync() == 0) {
      return History(spiffs: [], searches: [], tracks: {}, stream: [], videos: []);
    }

    final json = await file.readAsBytes().then(
      (body) => jsonDecode(utf8.decode(body)) as Map<String, dynamic>,
    );
    // Allow for older version w/o tracks
    if (json.containsKey('Tracks') == false) {
      json['Tracks'] = <String, TrackHistory>{};
    }
    // Allow for older version w/o radio
    if (json.containsKey('Stream') == false) {
      json['Stream'] = <StreamHistory>[];
    }
    // Allow for older version w/o movies
    if (json.containsKey('Videos') == false) {
      json['Videos'] = <VideoHistory>[];
    }

    final history = History.fromJson(json);
    // load with oldest first
    history.searches.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    history.spiffs.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    history.stream.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    history.videos.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return history;
  }

  static const maxSearchHistory = 25;
  static const maxSpiffHistory = 25;
  static const maxTrackHistory = 500;
  static const maxRadioHistory = 100;
  static const maxVideoHistory = 100;

  void _prune(History history) {
    if (history.searches.length > maxSearchHistory) {
      // remove oldest first
      history.searches.removeRange(
        0,
        history.searches.length - maxSearchHistory,
      );
    }
    if (history.spiffs.length > maxSpiffHistory) {
      // remove oldest first
      history.spiffs.removeRange(0, history.spiffs.length - maxSpiffHistory);
    }
    if (history.tracks.length > maxTrackHistory) {
      final oldestFirst = List<TrackHistory>.from(history.tracks.values);
      oldestFirst.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final takeCount = history.tracks.length - maxTrackHistory;
      if (takeCount > 0) {
        final taken = oldestFirst.take(takeCount);
        for (final e in taken) {
          history.tracks.remove(e.etag);
        }
      }
    }
    if (history.stream.length > maxRadioHistory) {
      // remove oldest first
      history.stream.removeRange(0, history.stream.length - maxRadioHistory);
    }
    if (history.videos.length > maxVideoHistory) {
      // remove oldest first
      history.videos.removeRange(0, history.videos.length - maxVideoHistory);
    }
  }

  Future<void> _save(File file, History history) async {
    final data = jsonEncode(history.toJson());
    try {
      await file.writeAsString(data);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<History> remove() async {
    final history = await _checkLoaded();
    history.searches.clear();
    history.spiffs.clear();
    history.tracks.clear();
    history.stream.clear();
    history.videos.clear();
    await _save(_file, history);
    return history;
  }
}
