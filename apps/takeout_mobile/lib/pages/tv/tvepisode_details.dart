import 'dart:math';

import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/video/play_movie.dart';
import 'package:takeout_lib/video/track.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/genre_page.dart';
import 'package:takeout_mobile/pages/film/person_details.dart';
import 'package:takeout_mobile/widgets/avatar_button.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/surface_theme.dart';

class TVEpisodeDetailsPage extends ClientPage<TVEpisodeView> {
  final TVEpisode _episode;

  TVEpisodeDetailsPage(this._episode, {super.key});

  TVEpisode get episode => _episode;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.tvEpisode(_episode.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, TVEpisodeView state) {
    final screen = MediaQuery.of(context).size;
    final landscape = screen.width > screen.height;
    final imgWidth = min<double>(screen.width * .9, 1440);
    final imgHeight = min<double>(screen.height * .5, 1080);
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            final offsetState = context.watch<OffsetCacheCubit>().state;
            final hasProgress = offsetState.hasValue(_episode);
            return SurfaceTheme(
              brightness: Brightness.dark,
              child: Builder(
                builder: (context) => SliverStack(
                  backdrop: state.series.backdrop,
                  slivers: [
                    SliverFavoriteBar(title: state.episode.name, onTap: () {}),
                    // SliverTitle(state.episode.name, style: context.header1),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsetsGeometry.all(20),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: imgWidth,
                                    maxHeight: imgHeight,
                                  ),
                                  child: MediaProgress.tvEpisode(
                                    episode,
                                    fillImage(
                                      context,
                                      episode.originalImage,
                                      width: landscape ? null : imgWidth,
                                      height: landscape ? imgHeight : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (hasProgress)
                                  DpadFocusable(
                                    onSelect: () => _onResume(context, state),
                                    child: FilledButton.icon(
                                      autofocus: true,
                                      onPressed: () =>
                                          _onResume(context, state),
                                      label: Text(context.strings.resumeLabel),
                                      icon: Icon(Icons.play_arrow),
                                    ),
                                  ),
                                if (hasProgress)
                                  DpadFocusable(
                                    onSelect: () => _onPlay(context, state),
                                    child: OutlinedButton.icon(
                                      onPressed: () => _onPlay(context, state),
                                      label: const Text('Play from start'),
                                      icon: const Icon(Icons.replay),
                                    ),
                                  )
                                else
                                  DpadFocusable(
                                    onSelect: () => _onPlay(context, state),
                                    child: FilledButton.icon(
                                      autofocus: true,
                                      onPressed: () => _onPlay(context, state),
                                      label: const Text('Play'),
                                      icon: const Icon(Icons.play_arrow),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        children: [
                                          if (episode.hasVotes) ...[
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              episode.vote,
                                              style: context.body,
                                            ),
                                            SizedBox(width: 16),
                                          ],
                                          if (state.series.hasRating) ...[
                                            Text(
                                              state.series.rating,
                                              style: context.body,
                                            ),
                                            SizedBox(width: 16),
                                          ],
                                          Text(
                                            '${episode.year}',
                                            style: context.body,
                                          ),
                                          SizedBox(width: 16),
                                          Text(
                                            context.strings.seasonLabel(
                                              episode.season,
                                            ),
                                            style: context.body,
                                          ),
                                          SizedBox(width: 16),
                                          Text(
                                            context.strings.episodeLabel(
                                              episode.episode,
                                            ),
                                            style: context.body,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              context.strings.synopsisLabel,
                              style: context.header2,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.30),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                episode.overview,
                                style: context.synopsis,
                              ),
                            ),
                            // Cast section
                            if (state.hasCast()) ...[
                              const SizedBox(height: 32),
                              Text(
                                context.strings.castLabel,
                                style: context.header2,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 140,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    ...state.cast!.map(
                                      (cast) => AvatarButton(
                                        name: cast.person.name,
                                        imageUrl: cast.person.image,
                                        onTap: () =>
                                            _onPerson(context, cast.person),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => GenrePage(genre));
  }

  void _onSeason(BuildContext context, int season) {
    // push(context, builder: (_) => SeasonDetailsPage(series, season));
  }

  void _onPlay(BuildContext context, TVEpisodeView view) {
    playMovie(context, TVEpisodeMediaTrack(view));
  }

  void _onResume(BuildContext context, TVEpisodeView view) {
    playMovie(
      context,
      TVEpisodeMediaTrack(view),
      startOffset: context.offsets.state.position(view.episode),
    );
  }

  void _onPerson(BuildContext context, Person person) {
    push(context, builder: (_) => PersonDetailsPage(person));
  }
}
