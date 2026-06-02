import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/music/all_artists_grid.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EpisodeDetailsPage extends StatelessWidget {
  final Episode _episode;

  const EpisodeDetailsPage(this._episode, {super.key});

  Episode get episode => _episode;

  @override
  Widget build(BuildContext context) {
    final state = _episode;
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<TrackCacheCubit, TrackCacheState>(
        builder: (context, cacheState) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background poster
              // backdropImage(context, state.background ?? ''),

              // Dark overlay
              Container(color: Colors.black.withValues(alpha: 0.65)),

              // Blur effect
              // BackdropFilter(
              //   filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), //12
              //   child: Container(
              //     color: Colors.black.withOpacity(0.2), // 0.2
              //   ),
              // ),
              SafeArea(
                child: Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: true,
                  child: CustomScrollView(
                    slivers: [
                      SliverMenuBar(
                        title: episode.title,
                        items: [
                          PopupItem.play(
                            context,
                            (_) => _onPlay(context, state),
                          ),
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
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsetsGeometry.all(20),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Row(
                                crossAxisAlignment: .start,
                                mainAxisAlignment: .start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: screen.width * .9,
                                    ),
                                    height: screen.height * .5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: fillImage(context, episode.image),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => _onPlay(context, state),
                                    label: Text('Play'),
                                    icon: Icon(Icons.play_arrow),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  // Movie details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          children: [
                                            Text(
                                              ymd(state.date),
                                              style: AppTextStyle.musicYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              state.author,
                                              style:
                                                  AppTextStyle.musicTrackCount,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              SizedBox(child: EpisodeDescription(state)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => AllArtistsGrid(genre: genre));
  }

  void _onPlay(BuildContext context, Episode episode) {
    context.playlist.replace(
      episode.reference,
      creator: episode.creator,
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
