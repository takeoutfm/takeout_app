// Copyright 2023 defsub
//
// This file is part of Takeout.
//
// Takeout is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recase/recase.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/builder.dart';
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'menu.dart';
import 'nav.dart';
import 'release.dart';
import 'style.dart';
import 'want.dart';

class ArtistsWidget extends NavigatorClientPage<ArtistsView> {
  final String? genre;
  final String? area;

  ArtistsWidget({this.genre, this.area, super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.artists(ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ArtistsView state) {
    return Scaffold(
        appBar: AppBar(title: _title(context), actions: [
          popupMenu(context, [
            PopupItem.reload(context, (_) => reloadPage(context)),
          ])
        ]),
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: ArtistListWidget(_artists(state))));
  }

  Widget _title(BuildContext context) {
    final artistsText = context.strings.artistsLabel;
    return genre != null
        ? header('$artistsText \u2013 $genre')
        : area != null
            ? header('$artistsText \u2013 $area')
            : header(artistsText);
  }

  List<Artist> _artists(ArtistsView view) {
    return genre != null
        ? view.artists.where((a) => a.genre == genre).toList()
        : area != null
            ? view.artists.where((a) => a.area == area).toList()
            : view.artists;
  }
}

String _subtitle(Artist artist) {
  final genre = ReCase(artist.genre ?? '').titleCase;

  if (isNullOrEmpty(artist.date)) {
    // no date, return genre
    return genre;
  }

  final y = year(artist.date ?? '');
  if (y.isEmpty) {
    // parsed date empty, return genre
    return genre;
  }

  // no genre, return year
  if (isNullOrEmpty(artist.genre)) {
    return y;
  }

  // have both
  return merge([genre, y]);
}

class ArtistListWidget extends StatelessWidget {
  final List<Artist> _artists;

  const ArtistListWidget(this._artists, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: ListView.builder(
              itemCount: _artists.length,
              itemBuilder: (buildContext, index) {
                final artist = _artists[index];
                return ListTile(
                    onTap: () => _onArtist(context, artist),
                    title: Text(artist.name),
                    subtitle: Text(_subtitle(artist)));
              }))
    ]);
  }

  void _onArtist(BuildContext context, Artist artist) {
    push(context, builder: (_) => ArtistWidget(artist));
  }
}

class ArtistWidget extends ClientPage<ArtistView> with ArtistPage {
  final Artist _artist;

  ArtistWidget(this._artist, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.artist(_artist.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ArtistView state) {
    return artistPage(context, state);
  }

  void _onRadio(BuildContext context) {
    pushSpiff(
        context,
        (client, {Duration? ttl}) =>
            client.artistRadio(_artist.id, ttl: Duration.zero));
  }

  void _onShuffle(BuildContext context) {
    pushSpiff(
        context,
        (client, {Duration? ttl}) =>
            client.artistPlaylist(_artist.id, ttl: Duration.zero));
  }

  void _onSingles(BuildContext context) {
    pushSpiff(
        context,
        (client, {Duration? ttl}) =>
            client.artistSinglesPlaylist(_artist.id, ttl: ttl));
  }

  void _onPopular(BuildContext context) {
    pushSpiff(
        context,
        (client, {Duration? ttl}) =>
            client.artistPopularPlaylist(_artist.id, ttl: ttl));
  }

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => ArtistsWidget(genre: genre));
  }

  void _onArea(BuildContext context, String area) {
    push(context, builder: (_) => ArtistsWidget(area: area));
  }

  void _onWantList(BuildContext context) {
    push(context, builder: (_) => ArtistWantListWidget(_artist));
  }

  @override
  List<Widget> actions(BuildContext context, ArtistView view) {
    final artistUrl = 'https://musicbrainz.org/artist/${_artist.arid}';
    final genre = ReCase(_artist.genre ?? '').titleCase;
    return <Widget>[
      popupMenu(context, [
        PopupItem.shuffle(context, (_) => _onShuffle(context)),
        PopupItem.radio(context, (_) => _onRadio(context)),
        PopupItem.divider(),
        PopupItem.singles(context, (_) => _onSingles(context)),
        PopupItem.popular(context, (_) => _onPopular(context)),
        PopupItem.divider(),
        if (_artist.genre != null)
          PopupItem.genre(
              context, genre, (_) => _onGenre(context, _artist.genre!)),
        if (_artist.area != null)
          PopupItem.area(
              context, _artist.area!, (_) => _onArea(context, _artist.area!)),
        PopupItem.divider(),
        PopupItem.link(context, 'MusicBrainz Artist',
            (_) => launchUrl(Uri.parse(artistUrl))),
        PopupItem.divider(),
        PopupItem.wantList(context, (_) => _onWantList(context)),
        PopupItem.reload(context, (_) => reloadPage(context)),
      ])
    ];
  }

  @override
  Widget leftButton(BuildContext context) {
    return IconButton(
        // color: overlayIconColor(context),
        icon: const Icon(Icons.shuffle_sharp),
        onPressed: () => _onShuffle(context));
  }

  @override
  Widget rightButton(BuildContext context) {
    return IconButton(
        // color: overlayIconColor(context),
        icon: const Icon(Icons.radio),
        onPressed: () => _onRadio(context));
  }

  @override
  List<Widget> slivers(BuildContext context, ArtistView view) {
    return [
      SliverToBoxAdapter(child: heading(context.strings.releasesLabel)),
      AlbumGridWidget(
        view.releases,
        subtitle: false,
      ),
      if (view.similar.isNotEmpty)
        SliverToBoxAdapter(child: heading(context.strings.similarArtists)),
      if (view.similar.isNotEmpty)
        SliverToBoxAdapter(child: SimilarArtistListWidget(view))
    ];
  }
}

class SimilarArtistListWidget extends StatelessWidget {
  final ArtistView _view;

  const SimilarArtistListWidget(this._view, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._view.similar.map((a) => ListTile(
          onTap: () => _onArtist(context, a),
          title: Text(a.name),
          subtitle: Text(_subtitle(a))))
    ]);
  }

  void _onArtist(BuildContext context, Artist artist) {
    push(context, builder: (_) => ArtistWidget(artist));
  }
}

mixin ArtistPage {
  List<Widget> actions(BuildContext context, ArtistView view);

  Widget leftButton(BuildContext context);

  Widget rightButton(BuildContext context);

  List<Widget> slivers(BuildContext context, ArtistView view);

  static final Random _random = Random();

  String? _randomCover(ArtistView view) {
    if (view.releases.isEmpty) {
      return null;
    }
    for (var i = 0; i < 3; i++) {
      final pick = _random.nextInt(view.releases.length);
      if (isNotNullOrEmpty(view.releases[pick].image)) {
        return view.releases[pick].image;
      }
    }
    try {
      return view.releases.firstWhere((r) => isNotNullOrEmpty(r.image)).image;
    } on StateError {
      return null;
    }
  }

  Widget artistPage(BuildContext context, ArtistView view) {
    // artist backgrounds are 1920x1080, expand keeping aspect ratio
    // artist images are 1000x1000
    // artist banners are 1000x185
    // final screen = MediaQuery.of(context).size;
    // final expandedHeight = useBackground
    //     ? 1080.0 / 1920.0 * screen.width
    //     : screen.height / 2;
    final screen = MediaQuery.of(context).size;
    final expandedHeight = screen.height / 2;

    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
        builder: (context, state) {
      final settings = context.settings.state.settings;
      final allow = settings.allowMobileArtistArtwork;
      String? image;
      if (state.mobile ? allow : true) {
        image = view.image;
      }
      final artwork = ArtworkBuilder.artist(image, _randomCover(view));
      final artistImage = artwork.build(context);
      return StreamBuilder<String?>(
          stream: artwork.urlStream.stream.distinct(),
          builder: (context, snapshot) {
            final url = snapshot.data;
            return FutureBuilder<Color?>(
                future: url != null
                    ? artwork.getBackgroundColor(context)
                    : Future.value(),
                builder: (context, snapshot) => Scaffold(
                    backgroundColor: snapshot.data,
                    body: CustomScrollView(slivers: [
                      SliverAppBar(
                          expandedHeight: expandedHeight,
                          actions: actions(context, view),
                          flexibleSpace: FlexibleSpaceBar(
                              stretchModes: const [
                                StretchMode.zoomBackground,
                                StretchMode.fadeTitle
                              ],
                              background:
                                  Stack(fit: StackFit.expand, children: [
                                artistImage,
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(0.0, 0.75),
                                      end: Alignment(0.0, 0.0),
                                      colors: <Color>[
                                        Color(0x60000000),
                                        Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: leftButton(context)),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: rightButton(context)),
                              ]))),
                      SliverToBoxAdapter(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                              child: Column(children: [
                                Text(view.artist.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall)
                              ]))),
                      ...slivers(context, view)
                    ])));
          });
    });
  }
}
