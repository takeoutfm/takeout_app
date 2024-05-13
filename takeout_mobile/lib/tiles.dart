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

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/util.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';

class AlbumListTile extends StatelessWidget {
  final String? artist;
  final String album;
  final String cover;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? _leading;
  final Widget? trailing;
  final bool selected;

  AlbumListTile(BuildContext context, this.artist, this.album, this.cover,
      {super.key,
      Widget? leading,
      this.onTap,
      this.onLongPress,
      this.trailing,
      this.selected = false})
      : _leading = leading ?? tileCover(context, cover);

  @override
  Widget build(BuildContext context) {
    final subtitle =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      if (artist != null) Text(artist ?? '', overflow: TextOverflow.ellipsis)
    ]);

    return ListTile(
        selected: selected,
        isThreeLine: artist != null,
        onTap: onTap,
        onLongPress: onLongPress,
        leading: _leading,
        trailing: trailing,
        subtitle: subtitle,
        title: Text(album));
  }
}

class TrackListTile extends StatelessWidget {
  final String artist;
  final String album;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;

  const TrackListTile(this.artist, this.album, this.title,
      {super.key,
      this.leading,
      this.onTap,
      this.onLongPress,
      this.trailing,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      if (artist.isNotEmpty) Text(artist, overflow: TextOverflow.ellipsis),
      Text(album, overflow: TextOverflow.ellipsis)
    ]);

    return ListTile(
        selected: selected,
        isThreeLine: artist.isNotEmpty,
        onTap: onTap,
        onLongPress: onLongPress,
        leading: leading,
        trailing: trailing,
        subtitle: subtitle,
        title: Text(title));
  }
}

class NumberedTrackListTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool selected;

  const NumberedTrackListTile(this.track,
      {super.key,
      this.onTap,
      this.onLongPress,
      this.trailing,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    final trackNumStyle = Theme.of(context).textTheme.bodySmall;
    final leading = Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
        child: Text('${track.trackNum}', style: trackNumStyle));
    // only show artist if different from album artist
    final artist = track.trackArtist != track.artist ? track.trackArtist : '';
    return TrackListTile(artist, track.releaseTitle, track.title,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        selected: selected);
  }
}

class CoverTrackListTile extends TrackListTile {
  CoverTrackListTile(BuildContext context, super.artist, super.album,
      super.title, String? cover,
      {super.key,
      super.onTap,
      super.onLongPress,
      super.trailing,
      super.selected})
      : super(leading: cover != null ? tileCover(context, cover) : null);

  factory CoverTrackListTile.mediaTrack(BuildContext context, MediaTrack track,
      {bool showCover = true,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
      Widget? trailing,
      bool selected = false}) {
    return CoverTrackListTile(
      context,
      track.creator,
      track.album,
      track.title,
      showCover ? track.image : null,
      onTap: onTap,
      onLongPress: onLongPress,
      trailing: trailing,
      selected: selected,
    );
  }

  factory CoverTrackListTile.mediaItem(BuildContext context, MediaItem item,
      {bool showCover = true,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
      Widget? trailing,
      bool selected = false}) {
    return CoverTrackListTile(
      context,
      item.artist ?? '',
      item.album ?? '',
      item.title,
      showCover ? item.artUri.toString() : null,
      onTap: onTap,
      onLongPress: onLongPress,
      trailing: trailing,
      selected: selected,
    );
  }
}

abstract class _ConnectivityTile extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? subtitle;
  final bool isThreeLine;

  const _ConnectivityTile(
      {super.key,
      this.onTap,
      this.leading,
      this.trailing,
      this.title,
      this.subtitle,
      this.isThreeLine = false});

  bool _enabled(BuildContext context, ConnectivityState state);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
      return ListTile(
        enabled: _enabled(context, state),
        onTap: onTap,
        leading: leading,
        trailing: trailing,
        title: title,
        subtitle: subtitle,
        isThreeLine: isThreeLine,
      );
    });
  }
}

class StreamingTile extends _ConnectivityTile {
  const StreamingTile(
      {super.key,
      super.onTap,
      super.leading,
      super.trailing,
      super.title,
      super.subtitle,
      super.isThreeLine});

  @override
  bool _enabled(BuildContext context, ConnectivityState state) {
    final settings = context.settings.state.settings;
    final allow = settings.allowMobileStreaming;
    return state.mobile ? allow : true;
  }
}

class RelativeDateWidget extends StatelessWidget {
  final DateTime dateTime;
  final String prefix;
  final String suffix;
  final String separator;

  const RelativeDateWidget(this.dateTime,
      {super.key,
      this.prefix = '',
      this.suffix = '',
      this.separator = textSeparator});

  factory RelativeDateWidget.from(String date,
      {String prefix = '',
      String suffix = '',
      String separator = textSeparator}) {
    try {
      final t = DateTime.parse(date);
      return RelativeDateWidget(t,
          prefix: prefix, suffix: suffix, separator: separator);
    } on FormatException {
      return RelativeDateWidget(DateTime(1, 1, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dateTime.year == 1 && dateTime.month == 1 && dateTime.day == 1) {
      // don't bother zero dates from the server
      return const Text('');
    }
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      // less than 1 day, refresh faster if less than 1 hour
      final refreshRate = diff.inHours > 0
          ? const Duration(hours: 1)
          : const Duration(minutes: 1);
      return Timeago(
          refreshRate: refreshRate,
          date: dateTime,
          builder: (_, v) {
            return Text(merge([prefix, v, suffix], separator: separator),
                overflow: TextOverflow.ellipsis);
          });
    } else {
      // more than 1 day so don't bother refreshing
      return Text(merge([prefix, timeago.format(dateTime), suffix]));
    }
  }
}
