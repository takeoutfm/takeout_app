import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/app/text_style.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre.dart';
import 'package:takeout_mobile/pages/film/play_movie.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/music/release_tracks.dart';
import 'package:takeout_mobile/pages/people.dart';
import 'package:takeout_mobile/widgets/chip.dart';
import 'package:takeout_mobile/widgets/circle_button.dart';

class ReleaseDetailsPage extends ClientPage<ReleaseView> {
  final Release _release;

  ReleaseDetailsPage(this._release, {super.key});

  Release get release => _release;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.release(_release.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ReleaseView state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background poster
                backdropImage(
                  context,
                  'https://assets.fanart.tv/fanart/twenty-one-pilots-538ed3f0944cf.jpg',
                ),

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
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        pinned: true,
                        leading: CircleButton.back(
                          onTap: () => Navigator.pop(context),
                        ),
                        actions: [CircleButton.favorite(onTap: () {})],
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsetsGeometry.all(20),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              // Movie content
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: releaseSmallCover(
                                      context,
                                      release.image,
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  // Movie details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          release.name,
                                          style: AppTextStyle.musicReleaseTitle,
                                        ),

                                        const SizedBox(height: 12),

                                        Text(
                                          release.artist,
                                          style: AppTextStyle.musicArtist,
                                        ),

                                        const SizedBox(height: 12),

                                        Wrap(
                                          children: [
                                            Text(
                                              '${release.year}',
                                              style: AppTextStyle.musicYear,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              context.strings.trackCount(
                                                state.tracks.length,
                                              ),
                                              style:
                                                  AppTextStyle.musicTrackCount,
                                            ),
                                            SizedBox(width: 16),
                                            Text(
                                              context.strings.discCount(
                                                state.discs,
                                              ),
                                              style:
                                                  AppTextStyle.musicDiscCount,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            MyChip(
                                              label: state.artist.genre ?? '',
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

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

                              const SizedBox(height: 40),

                              // Tracks
                              // const Text(
                              //   'Tracks',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 24,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              //
                              // const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.50),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ReleaseTracks(state),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AlbumGrid(
                        state.similar,
                        padding: EdgeInsetsGeometry.only(
                          left: albumGridEdgeInset,
                          right: albumGridEdgeInset,
                          bottom: albumGridEdgeInset,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => GenrePage(genre));
  }

  void _onPlay(BuildContext context, ReleaseView view) {
    // playMovie(context, MovieMediaTrack(view));
  }

  void _onResume(BuildContext context, MovieView view) {
    playMovie(
      context,
      MovieMediaTrack(view),
      startOffset: context.offsets.state.position(view.movie),
    );
  }

  void _onPerson(BuildContext context, Person person) {
    push(context, builder: (_) => ProfileWidget(person));
  }
}
