import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_box.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/tiles.dart';

class EpisodeDetailsPage extends StatelessWidget {
  final Episode _episode;

  const EpisodeDetailsPage(this._episode, {super.key});

  Episode get episode => _episode;

  @override
  Widget build(BuildContext context) {
    final state = _episode;
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.green,
      body: BlocBuilder<TrackCacheCubit, TrackCacheState>(
        builder: (context, cacheState) {
          final offsetCache = context.watch<OffsetCacheCubit>().state;
          final trackCache = context.watch<TrackCacheCubit>().state;
          final hasProgress = offsetCache.hasValue(_episode);
          // final when = offsetCache.when(episode);
          final duration = offsetCache.duration(episode);
          final remaining = offsetCache.remaining(episode);
          // final isCached = trackCache.contains(episode);
          return SliverStack(
            slivers: [
              SliverMenuBar(
                title: episode.title,
                items: [
                  PopupItem.play(context, (_) => _onPlay(context, state)),
                  PopupItem.download(
                    context,
                    (_) => _onDownload(context, state),
                  ),
                  PopupItem.playlistAppend(
                    context,
                    (_) => _onPlaylistAppend(context, state),
                  ),
                ],
              ),
              SliverBox(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: screen.width * .9,
                        maxHeight: screen.height * .5,
                      ),
                      child: MediaProgress.episode(
                        episode,
                        fillImage(context, episode.image),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (hasProgress)
                          FilledButton.icon(
                            autofocus: true,
                            onPressed: () => {}, // _onResume(context, state),
                            label: Text(context.strings.resumeLabel),
                            icon: Icon(Icons.play_arrow),
                          ),
                        FilledButton.icon(
                          autofocus: hasProgress == false,
                          onPressed: () => _onPlay(context, state),
                          label: Text(context.strings.playLabel),
                          icon: Icon(Icons.play_arrow),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: [
                                  Text(ymd(state.date), style: context.body),
                                  SizedBox(width: 16),
                                  if (duration != null) ...[
                                    Text(duration.inHoursMinutes),
                                    if (remaining != null) ...[
                                      SizedBox(width: 16),
                                      Text(
                                        context.strings.timeRemaining(
                                          remaining.inHoursMinutes,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: EpisodeDescription(state),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onPlay(BuildContext context, Episode episode) {
    context.playlist.replace(
      episode.reference,
      creator: episode.creator,
      mediaType: MediaType.podcast,
      title: episode.title,
    );
  }

  void _onDownload(BuildContext context, Episode episode) {
    context.downloadEpisode(episode);
  }

  void _onPlaylistAppend(BuildContext context, Episode episode) {
    showPlaylistAppend(context, episode.reference);
  }
}

class EpisodeDescription extends StatelessWidget {
  final Episode episode;

  const EpisodeDescription(this.episode, {super.key});

  @override
  Widget build(BuildContext context) {
    // TODO consider changing CSS font colors based on theme
    // controller.loadHtmlString("""<!DOCTYPE html>
    // <html>
    //   <head><meta name='viewport' content='width=device-width, initial-scale=1.0'></head>
    //   <body style='margin: 48;'>
    //     <div>
    //       ${episode.description}
    //     </div>
    //   </body>
    // </html>""");

    return HtmlWidget(episode.description);
  }
}
