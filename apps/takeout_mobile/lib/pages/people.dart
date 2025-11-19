// Copyright 2025 defsub
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
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/art/scaffold.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film.dart';
import 'package:takeout_mobile/pages/tv.dart';
import 'package:takeout_mobile/widgets/style.dart';

class ProfileWidget extends ClientPage<ProfileView> {
  final Person _person;

  ProfileWidget(this._person, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.profile(_person.peid, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ProfileView state) {
    return scaffold(
      context,
      image: _person.image,
      body: (_) => RefreshIndicator(
        onRefresh: () => reloadPage(context),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              // actions: [ ],
              expandedHeight: MediaQuery.of(context).size.height / 2,
              flexibleSpace: FlexibleSpaceBar(
                // centerTitle: true,
                // title: Text(release.name, style: TextStyle(fontSize: 15)),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    releaseSmallCover(context, _person.image),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.75),
                          end: Alignment(0.0, 0.0),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                child: Column(children: [_title(context)]),
              ),
            ),
            if (state.hasStarringMovies() || state.hasStarringShows())
              SliverToBoxAdapter(child: heading(context.strings.starringLabel)),
            if (state.hasStarringMovies())
              MovieGridWidget(state.starringMovies()),
            if (state.hasStarringShows())
              TVSeriesGridWidget(state.starringShows()),
            if (state.hasDirecting())
              SliverToBoxAdapter(
                child: heading(context.strings.directingLabel),
              ),
            if (state.hasDirecting()) MovieGridWidget(state.directingMovies()),
            if (state.hasWriting())
              SliverToBoxAdapter(child: heading(context.strings.writingLabel)),
            if (state.hasWriting()) MovieGridWidget(state.writingMovies()),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Text(_person.name, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class CastListWidget extends StatelessWidget {
  final List<Role> cast;

  const CastListWidget(this.cast, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...cast.map(
          (c) => ListTile(
            onTap: () => _onCast(context, c),
            title: Text(c.person.name),
            subtitle: Text(c.role),
          ),
        ),
      ],
    );
  }

  void _onCast(BuildContext context, Role role) {
    push(context, builder: (_) => ProfileWidget(role.person));
  }
}

class CrewListWidget extends StatelessWidget {
  final List<Role> crew;

  const CrewListWidget(this.crew, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...crew.map(
          (c) => ListTile(
            onTap: () => _onCrew(context, c),
            title: Text(c.person.name),
            subtitle: Text(c.role),
          ),
        ),
      ],
    );
  }

  void _onCrew(BuildContext context, Role role) {
    push(context, builder: (_) => ProfileWidget(role.person));
  }
}
