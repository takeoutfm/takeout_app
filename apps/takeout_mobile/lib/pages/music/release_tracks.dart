import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/style.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

class ReleaseTracks extends StatelessWidget {
  final ReleaseView _view;

  const ReleaseTracks(this._view, {super.key});

  void _onPlay(BuildContext context, int index) {
    context.playlist.replace(
      _view.release.reference,
      index: index,
      creator: _view.release.creator,
      title: _view.release.name,
    );
  }

  void _onLongPress(BuildContext context, Track t, RelativeRect pos) {
    showPopupMenu(context, pos, [
      PopupItem.trackPlaylist(context, (_) {
        pushSpiff(
          ref: '/music/tracks/${t.id}/playlist',
          context,
          (client, {Duration? ttl}) =>
              client.trackPlaylist('${t.id}', ttl: Duration.zero),
        );
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final downloads = context.watch<DownloadCubit>();
        final trackCache = context.watch<TrackCacheCubit>();
        int discs = _view.discs;
        int d = 0;
        List<Widget> children = [];
        for (var i = 0; i < _view.tracks.length; i++) {
          final e = _view.tracks[i];
          if (discs > 1 && e.discNum != d) {
            // if (e.discNum > 1) {
            //   children.add(const Divider());
            // }
            children.add(
              Text(
                context.strings.discLabel(e.discNum, discs),
                style: AppTextStyle.musicDiscNumber,
              ),
            );
            d = e.discNum;
          }
          children.add(
            GestureDetector(
              onDoubleTapDown: (d) {
                final offset = d.globalPosition;
                final pos = RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  MediaQuery.of(context).size.width - offset.dx,
                  MediaQuery.of(context).size.height - offset.dy,
                );
                _onLongPress(context, e, pos);
              },
              child: NumberedTrackListTile(
                e,
                onTap: () => _onPlay(context, i),
                trailing: _trailing(
                  context,
                  downloads.state,
                  trackCache.state,
                  e,
                ),
              ),
            ),
          );
          if (i + 1 != _view.tracks.length) {
            children.add(Divider());
          }
        }
        return Column(crossAxisAlignment: .start, children: children);
      },
    );
  }

  Widget? _trailing(
    BuildContext context,
    DownloadState downloadState,
    TrackCacheState trackCache,
    Track t,
  ) {
    if (trackCache.contains(t)) {
      return const Icon(iconsCached);
    }
    final progress = downloadState.progress(t);
    return (progress != null)
        ? CircularProgressIndicator(value: progress.value)
        : null;
  }
}
