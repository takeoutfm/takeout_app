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
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/favorite/favorite.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/music/artist_grid.dart';
import 'package:takeout_mobile/widgets/chip.dart';
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
    return Builder(
      builder: (context) {
        context.watch<MediaTypeCubit>();
        context.watch<FavoriteCubit>();
        final orientation = MediaQuery.of(context).orientation;
        final isAllArtists = genre == null && area == null;
        final title = isAllArtists
            ? null
            : genre?.titleCased ?? area?.titleCased;
        return RefreshIndicator(
          onRefresh: () => reloadPage(context),
          child: CustomScrollView(
            slivers: [
              if (isAllArtists && orientation == .landscape)
                _SliverArtistsBar(),
              if (!isAllArtists)
                SliverMenuBar(
                  title: title,
                  items: [
                    PopupItem.reload(context, (_) => reloadPage(context)),
                  ],
                ),
              SliverArtistGrid(_artists(context, state)),
            ],
          ),
        );
      },
    );
  }

  List<Artist> _artists(BuildContext context, ArtistsView view) {
    final artistType = context.selectedMediaType.state.artistType;
    print(artistType);
    if (artistType == .favorite) {
      print(
        context.favorite.state.favorite
            .sortedArtists()
            .map((a) => a.name)
            .toList(),
      );
      return context.favorite.state.favorite.sortedArtists().toList();
    }
    return genre != null
        ? view.artists.where((a) => a.genre == genre).toList()
        : area != null
        ? view.artists.where((a) => a.area == area).toList()
        : view.artists;
  }
}

final selectedIcon = Icons.check;

class _SliverArtistsBar extends SliverActionBar {
  @override
  List<MyChip> actions(BuildContext context) {
    final state = context.selectedMediaType.state;
    return [
      MyChip(
        icon: state.artistType == .all ? selectedIcon : null,
        label: 'All Artists',
        onTap: () {
          context.selectedMediaType.select(.music, artistType: .all);
        },
      ),
      MyChip(
        icon: state.artistType == .favorite ? selectedIcon : null,
        label: 'Favorite Artists',
        onTap: () {
          context.selectedMediaType.select(.music, artistType: .favorite);
        },
      ),
    ];
  }
}
