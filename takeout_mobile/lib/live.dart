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

// import 'dart:async';
import 'dart:collection';
// import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
// import 'package:logging/logging.dart';
// import 'package:rxdart/rxdart.dart';
import 'package:takeout_lib/model.dart';
// import 'package:wakelock/wakelock.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

part 'live.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal, includeIfNull: false)
class EventPlaybackState {
  final bool playing;
  final int position;
  final int latency;

  EventPlaybackState(
      {required this.playing, required this.position, this.latency = 0});

  factory EventPlaybackState.fromPlaybackState(
      PlaybackState state, int latency) {
    return EventPlaybackState(
        playing: state.playing,
        position: state.position.inMilliseconds,
        latency: latency);
  }

  factory EventPlaybackState.fromJson(Map<String, dynamic> json) =>
      _$EventPlaybackStateFromJson(json);

  Map<String, dynamic> toJson() => _$EventPlaybackStateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal, includeIfNull: false)
class EventTrack implements MediaTrack {
  @override
  final String creator;
  @override
  final String album;
  @override
  final String title;
  @override
  final String image;
  @override
  final String location;
  @override
  final String etag;

  EventTrack({
    required this.creator,
    required this.album,
    required this.title,
    this.image = '',
    required this.location,
    this.etag = '',
  });

  factory EventTrack.fromMediaItem(MediaItem item) {
    return EventTrack(
        creator: item.artist ?? '',
        album: item.album ?? '',
        title: item.title,
        image: item.artUri.toString(),
        location: '',
        //item.extras?['TODO'],
        etag: ''); //item.extras?['TODO']);
  }

  factory EventTrack.fromJson(Map<String, dynamic> json) =>
      _$EventTrackFromJson(json);

  Map<String, dynamic> toJson() => _$EventTrackToJson(this);

  @override
  int get size => 0;

  @override
  int get year => throw UnimplementedError;

  @override
  int get number => throw UnimplementedError;

  @override
  int get disc => throw UnimplementedError;

  @override
  String get date => '1970';
}

@JsonSerializable(fieldRename: FieldRename.pascal, includeIfNull: false)
class Event {
  EventTrack? track;
  EventTrack? nextTrack;
  EventPlaybackState? playbackState;

  Event({this.track, this.playbackState, this.nextTrack});

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);

  bool isTrack() {
    return track != null;
  }

  bool isPlaybackState() {
    return playbackState != null;
  }

  bool hasNextTrack() {
    return nextTrack != null;
  }
}

class Latency {
  final int size;
  final q = Queue<int>();

  Latency({this.size = 3});

  void add(int val) {
    if (val > 1000) {
      // ignore values > 1 second
      return;
    }
    while (q.length >= size) {
      q.removeLast();
    }
    q.addFirst(val);
  }

  double get value {
    return q.isNotEmpty ? q.average : 0;
  }
}

/*** TODO
class LiveClient {
  static final log = Logger('LiveClient');
  static const reconnectDelay = Duration(seconds: 3);
  final Uri uri;
  final String token;
  final eventSubject = PublishSubject<Event>();
  Latency? latency;
  WebSocketChannel? channel;
  Timer? latencyTimer;
  bool _allowReconnect = true;

  LiveClient(String host, this.token) : uri = Uri.parse('wss://$host/live');

  void connect() {
    Wakelock.enable();
    log.info('connecting to $uri');
    channel = WebSocketChannel.connect(uri);
    channel!.sink.add('/auth $token');
    listen();
  }

  void disconnect() {
    Wakelock.disable();
    _allowReconnect = false;
    channel?.sink.close();
    channel = null;
    latencyTimer?.cancel();
    latencyTimer = null;
  }

  void reconnect() {
    if (!_allowReconnect) {
      return;
    }
    log.info('reconnecting after $reconnectDelay');
    Future.delayed(reconnectDelay, () {
      connect();
    });
  }

  void sendPing(int time) {
    channel?.sink.add('/ping $time');
  }

  void send(Event event) {
    final json = jsonEncode(event.toJson());
    channel?.sink.add(utf8.encode(json));
  }

  void sendMediaItem(MediaItem mediaItem, MediaItem? nextItem) {
    send(Event(
        track: EventTrack.fromMediaItem(mediaItem),
        nextTrack:
            nextItem != null ? EventTrack.fromMediaItem(nextItem) : null));
  }

  void sendPlayback(PlaybackState playbackState) {
    send(Event(
        playbackState: EventPlaybackState.fromPlaybackState(
            playbackState, latency?.value.round() ?? 0)));
  }

  void listen() async {
    const latencyPingDuration = Duration(seconds: 15);
    latencyTimer?.cancel();
    latency = Latency();

    final doPing = (_) {
      sendPing(DateTime.now().millisecondsSinceEpoch);
    };
    latencyTimer = Timer.periodic(latencyPingDuration, doPing);
    doPing(latencyTimer);

    channel?.stream.listen(
        (event) {
          final msg = utf8.decode(event);
          log.fine('got $msg');
          if (msg.toString().startsWith('/')) {
            final cmd = msg.toString().split(' ');
            if (cmd[0] == '/pong') {
              final now = DateTime.now().millisecondsSinceEpoch;
              final time = int.tryParse(cmd[1]) ?? now;
              final l = (now - time) ~/ 2;
              latency?.add(l);
              log.fine('latency is $l (avg ${latency?.value})');
            }
          } else {
            eventSubject.add(Event.fromJson(jsonDecode(msg)));
          }
        },
        cancelOnError: true,
        onError: (error) {
          log.warning('error $error', error);
          reconnect();
        },
        onDone: () {
          log.fine('done');
          reconnect();
        });
  }
}

class LiveShare {
  static final log = Logger('LiveShare');

  final LiveClient client;
  final AudioHandler audioHandler;
  StreamSubscription? mediaItemSubscription;
  StreamSubscription? playbackStateSubscription;

  LiveShare(this.client, this.audioHandler);

  void stop() {
    log.info('stopping');
    client.disconnect();
    mediaItemSubscription?.cancel();
    mediaItemSubscription = null;
    playbackStateSubscription?.cancel();
    playbackStateSubscription = null;
  }

  void start() async {
    log.info('starting');
    client.connect();
    mediaItemSubscription = audioHandler.mediaItem
        // .debounceTime(Duration(seconds: 3))
        .distinct()
        .listen((mediaItem) {
      if (mediaItem == null) {
        return;
      }
      final queue = audioHandler.queue.value;
      final index = queue.indexOf(mediaItem);
      if (index + 1 < queue.length) {
        final nextItem = queue[index + 1];
        client.sendMediaItem(mediaItem, nextItem);
      } else {
        client.sendMediaItem(mediaItem, null);
      }
    });
    playbackStateSubscription = audioHandler.playbackState
        .distinct(
            /*(a, b) => a.playing == b.playing && a.position == b.position*/)
        .listen((playbackState) {
      client.sendPlayback(playbackState);
    });
  }
}

class LiveFollow {
  static final log = Logger('LiveFollow');

  final LiveClient client;
  final AudioHandler audioHandler;
  StreamSubscription? eventSubscription;

  LiveFollow(this.client, this.audioHandler);

  void _enqueueNextTrack(EventTrack track) async {
    final index = _trackQueueIndex(track);
    if (index == -1) {
      // final mediaItem = await MediaQueue.trackMediaItem(track);
      // audioHandler.addQueueItem(mediaItem);
    }
  }

  bool _isTrackCurrentItem(EventTrack track) {
    final currentItem = audioHandler.mediaItem.value;
    return currentItem?.extras?['TODO'] == track.key;
  }

  int _trackQueueIndex(EventTrack track) {
    final queue = audioHandler.queue.value;
    return queue.indexWhere((item) => item.extras?['TODO'] == track.key);
  }

  void stop() {
    log.info('stopping');
    client.disconnect();
    eventSubscription?.cancel();
    eventSubscription = null;
  }

  void start() async {
    log.info('starting');
    client.connect();
    client.eventSubject.listen((event) {
      if (event.isTrack()) {
        final track = event.track!;
        if (_isTrackCurrentItem(track) == false) {
          final index = _trackQueueIndex(track);
          if (index != -1) {
            audioHandler.skipToQueueItem(index);
          } else {
            // start with a new queue
            // MediaQueue.playTracks(<MediaLocatable>[
            //   event.track!,
            //   if (event.hasNextTrack()) event.nextTrack!
            // ]);
          }
        }
        if (event.hasNextTrack()) {
          _enqueueNextTrack(event.nextTrack!);
        }
      } else if (event.isPlaybackState()) {
        final eventState = event.playbackState!;
        if (eventState.playing) {
          final nextPos = eventState.position +
              eventState.latency +
              (client.latency?.value ?? 0);
          final pos = audioHandler.playbackState.value.position.inMilliseconds;
          final diff = (pos - nextPos).abs();
          if (diff > 50) {
            log.fine(
                'seek to $nextPos theirs=${eventState.position} ours=$pos diff=$diff');
            audioHandler.seek(Duration(milliseconds: nextPos.round()));
          }
          if (!audioHandler.playbackState.value.playing) {
            audioHandler.play();
          }
        } else {
          audioHandler.pause();
        }
      }
    });
  }
}
 ***/