import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:takeout_mobile/widgets/sliver_bar.dart';

class AllArtistsGrid extends ClientPage<ArtistsView> {
  final String? genre;
  final String? area;

  const AllArtistsGrid({this.genre, this.area, super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.artists(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ArtistsView state) {
    final isAllArtists = genre == null && area == null;
    final title = isAllArtists ? null : genre?.titleCased ?? area?.titleCased;
    return RefreshIndicator(
      onRefresh: () => reloadPage(context),
      child: CustomScrollView(
        slivers: [
          if (!isAllArtists)
            SliverMenuBar(
              title: title,
              items: [PopupItem.reload(context, (_) => reloadPage(context))],
            ),
          SliverArtistGrid(_artists(state)),
        ],
      ),
    );
  }

  List<Artist> _artists(ArtistsView view) {
    return genre != null
        ? view.artists.where((a) => a.genre == genre).toList()
        : area != null
        ? view.artists.where((a) => a.area == area).toList()
        : view.artists;
  }
}
