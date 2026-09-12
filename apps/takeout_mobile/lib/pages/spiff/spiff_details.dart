// Copyright 2026 defsub
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/client.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/pages/spiff/spiff_tracks.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/surface_theme.dart';

typedef FetchSpiff = Future<void> Function(ClientCubit, {Duration? ttl});

class SpiffDetailsPage extends ClientPage<Spiff> {
  final FetchSpiff? fetch;
  final String? ref;
  final String? title;

  const SpiffDetailsPage({
    super.key,
    super.value,
    this.fetch,
    this.ref,
    this.title,
  });

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) async {
    await fetch?.call(context.client, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, Spiff state) {
    return Builder(
      builder: (context) {
        final trackCache = context.watch<TrackCacheCubit>();
        final spiffCache = context.watch<SpiffCacheCubit>();
        final isDownloaded = spiffCache.state.contains(state);
        final isCached = trackCache.state.containsAll(state.playlist.tracks);
        return _body(context, state, isDownloaded || isCached);
      },
    );
  }

  Widget _body(BuildContext context, Spiff state, bool deleteAllowed) {
    String? background = state.playlist.background;
    if (background == null && state.isNotEmpty) {
      final t = state[state.index < 0 ? 0 : state.index];
      if (t.background.isNotEmpty) {
        background = t.background;
      }
    }
    final reference = ref;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return SurfaceTheme(
              brightness: Brightness.dark,
              child: Builder(
                builder: (context) => SliverStack(
                  backdrop: background,
                  slivers: [
                    SliverMenuBar(
                      // title: title,
                      items: [
                        if (fetch != null)
                          PopupItem.reload(context, (_) => reloadPage(context)),
                        PopupItem.shuffle(
                          context,
                          (_) => _onShuffle(context, state),
                        ),
                        if (reference != null)
                          PopupItem.playlistAppend(
                            context,
                            (_) => _onPlaylistAppend(context, reference),
                          ),
                        if (deleteAllowed)
                          PopupItem.delete(
                            context,
                            context.strings.deleteItem,
                            (_) => _onDelete(context, state),
                          ),
                      ],
                    ),
                    SliverBox(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const posterWidth = 223.0;
                          const minDetailsWidth = 300.0;
                          final hasRoom =
                              constraints.maxWidth >=
                              posterWidth + minDetailsWidth;
                          if (hasRoom) {
                            // wide view
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: .stretch,
                                children: [
                                  SizedBox(
                                    width: posterWidth,
                                    child: _spiffCover(context, state),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        mainAxisAlignment: .spaceBetween,
                                        children: [
                                          _spiffDetails(context, state),
                                          SizedBox(height: 16),
                                          _playButtons(context, state),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          // tall view
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _spiffCover(context, state),
                              const SizedBox(height: 16),
                              _playButtons(context, state),
                              const SizedBox(height: 16),
                              _spiffDetails(context, state, center: false),
                            ],
                          );
                        },
                      ),
                    ),
                    if (state.isNotLive && state.isNotPodcast)
                      SliverBox(
                        padding: EdgeInsetsGeometry.all(16),
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(16),
                          child: SpiffTracks(state),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _playButtons(BuildContext context, Spiff state) {
    final hasProgress = state.position > 0;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasProgress)
          FilledButton.icon(
            autofocus: true,
            onPressed: () => _onPlay(context, state),
            label: Text(context.strings.resumeLabel),
            icon: Icon(Icons.play_arrow),
          ),
        if (hasProgress)
          OutlinedButton.icon(
            autofocus: true,
            onPressed: () => _onPlay(context, state.copyWith(position: 0)),
            label: Text(context.strings.playFromStartLabel),
            icon: Icon(Icons.replay),
          )
        else
          FilledButton.icon(
            autofocus: true,
            onPressed: () => _onPlay(context, state),
            label: Text(context.strings.playLabel),
            icon: Icon(Icons.play_arrow),
          ),
      ],
    );
  }

  Widget _spiffCover(BuildContext context, Spiff state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: releaseSmallCover(context, state.cover),
    );
  }

  Widget _spiffDetails(
    BuildContext context,
    Spiff state, {
    bool center = false,
  }) {
    return Column(
      crossAxisAlignment: center ? .center : .start,
      children: [
        Text(state.playlist.title, style: context.header1),
        const SizedBox(height: 12),
        Text(state.creator ?? 'none', style: context.body),
        const SizedBox(height: 12),
        if (state.isNotLive && state.isNotPodcast) ...[
          Wrap(
            children: [
              Text(
                context.strings.trackCount(state.playlist.tracks.length),
                style: context.body,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MyChip(
                label: context.strings.shuffleLabel,
                onTap: () => _onShuffle(context, state),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _onPlay(BuildContext context, Spiff spiff) {
    if (spiff.isVideo) {
      final entry = spiff.playlist.tracks.first;
      context.showMovie(VideoTrack.fromEntry(entry));
    } else {
      context.play(spiff);
    }
  }

  void _onDelete(BuildContext context, Spiff spiff) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.strings.confirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {
                _onDeleteConfirmed(context, spiff);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
  }

  void _onDeleteConfirmed(BuildContext context, Spiff spiff) {
    context.remove(spiff);
  }

  void _onPlaylistAppend(BuildContext context, String reference) {
    showPlaylistAppend(context, reference);
  }

  void _onShuffle(BuildContext context, Spiff spiff) {
    context.client.result<Spiff>(spiff.shuffle());
  }
}
