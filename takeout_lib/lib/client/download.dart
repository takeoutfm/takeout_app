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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:takeout_lib/cache/track_repository.dart';

import 'repository.dart';

abstract class DownloadIdentifier implements TrackIdentifier {
  @override
  bool operator ==(Object other) {
    return (other is DownloadIdentifier) ? key == other.key : false;
  }

  @override
  int get hashCode => key.hashCode;
}

class Download extends Equatable {
  final DownloadIdentifier id;
  final Uri uri;
  final int size;
  final File? file;
  final DownloadProgress? progress;
  final DateTime _date;

  Download(this.id, this.uri, this.size,
      {this.file, this.progress, DateTime? date})
      : _date = date ?? DateTime.now();

  Download copyWith({File? file, DownloadProgress? progress}) =>
      Download(id, uri, size,
          date: date,
          file: file ?? this.file,
          progress: progress ?? this.progress);

  @override
  List<Object> get props => [id];

  @override
  bool? get stringify => true;

  /// Download is pending
  bool get pending => progress == null;

  /// Download in progress
  bool get downloading => progress != null && progress?.incomplete == true;

  /// Download is complete
  bool get complete => progress?.complete == true && file?.lengthSync() == size;

  DateTime get date => _date;
}

class DownloadProgress {
  final int offset;
  final int size;
  final Object? error;

  DownloadProgress(this.offset, this.size, {this.error});

  DownloadProgress copyWith({int? offset, Object? error}) =>
      DownloadProgress(offset ?? this.offset, size, error: error ?? this.error);

  // Value used for progress display.
  double get value {
    return offset.toDouble() / size;
  }

  bool get complete => offset == size;

  bool get incomplete => offset < size;
}

class DownloadAdd extends DownloadState {
  DownloadAdd(super.downloads, super.failed);

  /// Download added but not yet in progress
  factory DownloadAdd.from(DownloadState state, Download download) {
    final downloads =
        Map<DownloadIdentifier, Download>.fromEntries(state._downloads.entries);
    final failed =
        Map<DownloadIdentifier, Object?>.fromEntries(state._failed.entries);

    downloads[download.id] = download;
    failed.remove(download.id);

    return DownloadAdd(downloads, failed);
  }
}

class DownloadStart extends DownloadState {
  final DownloadIdentifier id;

  DownloadStart(this.id, super.downloads, super.failed);

  /// Download started
  factory DownloadStart.from(
      DownloadState state, DownloadIdentifier id, File file) {
    final downloads =
        Map<DownloadIdentifier, Download>.fromEntries(state._downloads.entries);
    final failed =
        Map<DownloadIdentifier, Object?>.fromEntries(state._failed.entries);

    final download = downloads[id];
    if (download != null) {
      downloads[id] = download.copyWith(
          file: file, progress: DownloadProgress(0, download.size));
    }

    return DownloadStart(id, downloads, failed);
  }
}

class DownloadUpdate extends DownloadState {
  final DownloadIdentifier id;

  DownloadUpdate(this.id, super.downloads, super.failed);

  /// Download progress updated
  factory DownloadUpdate.from(
      DownloadState state, DownloadIdentifier id, int offset) {
    final downloads =
        Map<DownloadIdentifier, Download>.fromEntries(state._downloads.entries);
    final failed =
        Map<DownloadIdentifier, Object?>.fromEntries(state._failed.entries);

    final download = downloads[id];
    if (download != null) {
      downloads[id] =
          download.copyWith(progress: DownloadProgress(offset, download.size));
    }

    return DownloadUpdate(id, downloads, failed);
  }
}

class DownloadComplete extends DownloadState {
  final DownloadIdentifier id;

  DownloadComplete(this.id, super.downloads, super.errors);

  /// Download completed
  factory DownloadComplete.from(
      DownloadState state, DownloadIdentifier id, int offset) {
    final downloads =
        Map<DownloadIdentifier, Download>.fromEntries(state._downloads.entries);
    final failed =
        Map<DownloadIdentifier, Object?>.fromEntries(state._failed.entries);

    final download = downloads[id];
    if (download != null) {
      downloads[id] =
          download.copyWith(progress: DownloadProgress(offset, download.size));
    }

    return DownloadComplete(id, downloads, failed);
  }
}

class DownloadError extends DownloadState {
  final DownloadIdentifier id;

  DownloadError(this.id, super.downloads, super.errors);

  /// Download failed with error
  factory DownloadError.from(
      DownloadState state, DownloadIdentifier id, Object? error) {
    final downloads =
        Map<DownloadIdentifier, Download>.fromEntries(state._downloads.entries);
    final failed =
        Map<DownloadIdentifier, Object?>.fromEntries(state._failed.entries);

    downloads.remove(id);
    failed[id] = error;

    return DownloadError(id, downloads, failed);
  }
}

class DownloadState {
  final Map<DownloadIdentifier, Download> _downloads;
  final Map<DownloadIdentifier, Object?> _failed;

  DownloadState(Map<DownloadIdentifier, Download> downloads,
      Map<DownloadIdentifier, Object?> failed)
      : _downloads = downloads,
        _failed = failed;

  factory DownloadState.initial() => DownloadState({}, {});

  // Map<DownloadIdentifier, Download> get downloads => Map<DownloadIdentifier, Download>.unmodifiable(_downloads);
  // Map<DownloadIdentifier, Object?> get failed => Map<DownloadIdentifier, Object?>.unmodifiable(_failed);

  Download? get(DownloadIdentifier id) => _downloads[id];

  DownloadProgress? progress(DownloadIdentifier id) => _downloads[id]?.progress;

  bool complete(DownloadIdentifier id) => _downloads[id]?.complete ?? false;

  /// Download for id is pending, in progress or complete
  bool contains(DownloadIdentifier id) => _downloads.containsKey(id);

  int get downloading => _downloads.values
      .fold(0, (count, d) => d.downloading ? count + 1 : count);

  Download? get next {
    try {
      // LinkedHashMap retains order
      return _downloads.values.firstWhere((d) => d.pending);
    } on StateError {
      return null;
    }
  }
}

class _ProgressSink implements Sink<int> {
  final void Function(int) update;
  int _offset = 0;

  _ProgressSink(this.update);

  @override
  void add(int chunk) {
    _offset += chunk;
    update(_offset);
  }

  @override
  void close() {}
}

class DownloadEvent {
  final DownloadIdentifier id;
  final Uri uri;
  final int size;

  DownloadEvent(this.id, this.uri, this.size);
}

class DownloadCubit extends Cubit<DownloadState> {
  final TrackCacheRepository trackCacheRepository;
  final ClientRepository clientRepository;

  DownloadCubit(
      {required this.trackCacheRepository, required this.clientRepository})
      : super(DownloadState.initial());

  void add(DownloadIdentifier id, Uri uri, int size) {
    _add(DownloadEvent(id, uri, size));
  }

  void addAll(Iterable<DownloadEvent> events) {
    for (var event in events) {
      _add(event);
    }
  }

  void check() {
    if (state.downloading == 0) {
      final next = state.next;
      if (next != null) {
        _start(next);
      }
    }
  }

  void _add(DownloadEvent event) {
    trackCacheRepository.contains(event.id).then((isCached) {
      if (!isCached) {
        if (state.contains(event.id) == false) {
          emit(DownloadAdd.from(
              state, Download(event.id, event.uri, event.size)));
        }
      }
    });
  }

  void _start(Download download) {
    final file = trackCacheRepository.create(download.id);
    emit(DownloadStart.from(state, download.id, file));

    // *must* emit state before async code
    clientRepository
        .download(download.uri, file, download.size,
            progress: _ProgressSink((offset) => _update(download.id, offset)))
        .then((_) => _complete(download.id))
        .onError((error, stackTrace) => _error(download.id, error));
  }

  void _update(DownloadIdentifier id, int offset) {
    emit(DownloadUpdate.from(state, id, offset));
  }

  void _complete(DownloadIdentifier id) {
    final download = state.get(id);
    final file = download?.file;
    if (file != null) {
      emit(DownloadComplete.from(state, id, file.lengthSync()));
      // *must* emit state before async code
      trackCacheRepository.put(id, file);
    }
  }

  void _error(DownloadIdentifier id, Object? error) {
    emit(DownloadError.from(state, id, error));
  }
}
