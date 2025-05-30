// Copyright 2023 defsub
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
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'menu.dart';

class ArtistWantListWidget extends ClientPage<WantListView> {
  final Artist _artist;

  ArtistWantListWidget(this._artist, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.artistWantList(_artist.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, WantListView state) {
    return Scaffold(
        appBar: AppBar(title: Text(_artist.name), actions: [
          popupMenu(context, [
            PopupItem.reload(context, (_) => reloadPage(context)),
          ])
        ]),
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: SingleChildScrollView(
                child: Column(children: [
              ...state.releases.map((release) =>
                  WantReleaseCard(artist: _artist, release: release))
            ]))));
  }
}

class WantReleaseCard extends StatelessWidget {
  final Artist artist;
  final Release release;

  const WantReleaseCard(
      {required this.artist, required this.release, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: tileCover(context, release.image),
              title: Text(release.name),
              subtitle: Text(merge([
                artist.name,
                release.year.toString(),
                release.country ?? '',
                release.asin ?? ''
              ])),
              onTap: () => _onAmazon(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (isNotNullOrEmpty(release.asin))
                  _link('Amazon', () => _onAmazon()),
                const SizedBox(width: 8),
                if (isNotNullOrEmpty(release.asin))
                  _link('CamelCamelCamel', () => _onCamelCamelCamel()),
                const SizedBox(width: 8),
                _link('MusicBrainz', () => _onMusicBrainz()),
                const SizedBox(width: 8),
                _link('Google', () => _onGoogle()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _link(String text, void Function() onPressed) {
    return TextButton(onPressed: onPressed, child: Text(text));
  }

  void _onAmazon() {
    final uri = 'https://www.amazon.com/dp/${release.asin}';
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  void _onCamelCamelCamel() {
    final uri = 'https://camelcamelcamel.com/product/${release.asin}';
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  void _onMusicBrainz() {
    final uri = 'https://musicbrainz.org/release-group/${release.rgid}';
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  void _onGoogle() {
    final uri =
        'https://www.google.com/search?q=${Uri.encodeQueryComponent("${release.name} by ${artist.name}")}';
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

// void _onWikipedia() {
//   final uri =
//       'https://en.wikipedia.org/w/index.php?title=Special:Search&search=${Uri
//       .encodeQueryComponent(release.name + " by " + artist.name)}';
//   launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
// }
}
