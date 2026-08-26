import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/music/album_grid.dart';
import 'package:takeout_mobile/pages/podcast/episode_grid.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';
import 'package:takeout_mobile/widgets/sliver_stack.dart';
import 'package:takeout_mobile/widgets/sliver_title.dart';

class SeriesDetailsPage extends ClientPage<SeriesView> {
  final Series _series;

    const SeriesDetailsPage(this._series, {super.key});

  Series get series => _series;

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.series(_series.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, SeriesView state) {
    final episodes = List<Episode>.from(
      state.episodes.map(
        (e) => e.copyWith(album: state.series.title),
        // (e) => e.copyWith(album: state.series.title, image: state.series.image),
      ),
    );
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
          builder: (context, cacheState) {
            return SliverStack(
              slivers: [
                SliverMenuBar(
                  title: series.title,
                  items: [
                    if (context.subscribed.state.isSubscribed(state.series))
                      PopupItem.unsubscribe(
                        context,
                            (context) => _onUnsubscribe(context, state.series),
                      )
                    else
                      PopupItem.subscribe(
                        context,
                            (context) => _onSubscribe(context, state.series),
                      ),
                    PopupItem.divider(),
                    PopupItem.reload(context, (_) => reloadPage(context)),
                  ],
                ),
                if (episodes.isNotEmpty) ...[
                  SliverTitle(
                    context.strings.episodesCount(episodes.length),
                    style: context.header2,
                  ),
                  SliverEpisodeGrid(
                    episodes,
                    padding: EdgeInsetsGeometry.only(
                      left: albumGridEdgeInset,
                      right: albumGridEdgeInset,
                      bottom: albumGridEdgeInset,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _onSubscribe(BuildContext context, Series series) {
    context.subscribed.subscribe(series);
  }

  void _onUnsubscribe(BuildContext context, Series series) {
    context.subscribed.unsubscribe(series);
  }
}
