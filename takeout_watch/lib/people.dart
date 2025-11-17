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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/list.dart';
import 'package:takeout_watch/media.dart';

class PeoplePage extends StatelessWidget {
  final String title;
  final List<Person> people;
  final MediaEntryCallback onMediaTap;

  const PeoplePage(this.title, this.people, this.onMediaTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            RotaryList<Person>(people, title: title, tileBuilder: personTile));
  }

  Widget personTile(BuildContext context, Person person) {
    return ListTile(
        leading: const Icon(Icons.person),
        title: Text(person.name),
        onTap: () => onPerson(context, person));
  }

  void onPerson(BuildContext context, Person person) {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (_) => ProfilePage(person, onMediaTap)));
  }
}

class ProfilePage extends ClientPage<ProfileView> {
  final Person person;
  final MediaEntryCallback? onLongPress;
  final MediaEntryCallback onTap;

  ProfilePage(this.person, this.onTap, {super.key, this.onLongPress});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.profile(person.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ProfileView state) {
    final movies = <Movie>[];
    if (state.movies.starring.isNotEmpty) {
      movies.addAll(state.movies.starring);
    }
    return MediaPage(
      movies,
      title: state.person.name,
      onLongPress: onLongPress,
      onTap: onTap,
    );
  }
}
