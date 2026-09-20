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
