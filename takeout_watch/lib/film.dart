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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_lib/video/player.dart';
import 'package:takeout_watch/app/context.dart';
import 'package:takeout_watch/dialog.dart';
import 'package:takeout_watch/list.dart';
import 'package:takeout_watch/media.dart';
import 'package:takeout_watch/nav.dart';
import 'package:takeout_watch/settings.dart';

class FilmPage extends StatelessWidget {
  final HomeView state;

  const FilmPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Movie> movies;
    switch (context.selectedMediaType.state.filmType) {
      case FilmType.added:
        movies = state.addedMovies;
      case FilmType.recent:
        movies = state.newMovies;
      case FilmType.recommended:
        final recommended = state.recommendMovies;
        if (recommended != null && recommended.isNotEmpty) {
          movies = recommended.first.movies ?? [];
        } else {
          movies = [];
        }
      case FilmType.all:
        // TODO all not supported yet
        movies = [];
    }
    return MediaPage(movies,
        title: context.strings.moviesLabel,
        onLongPress: (context, entry) => _onDownload(context, entry as Movie),
        onTap: (context, entry) => _onMovie(context, entry as Movie));
  }
}

class MovieEntry {
  final Widget? icon;
  final String? title;
  final String? subtitle;
  final void Function(BuildContext, MovieView)? onSelected;

  MovieEntry({this.icon, this.title, this.subtitle, this.onSelected});
}

class MoviePage extends ClientPage<MovieView> {
  final Movie movie;

  MoviePage(this.movie, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.movie(movie.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, MovieView state) {
    final offset = context.offsets.state.get(state.movie);
    final entries = [
      if (offset != null)
        MovieEntry(
            icon: const Icon(Icons.play_arrow),
            title: context.strings.resumeLabel,
            onSelected: onResume),
      MovieEntry(
          icon: const Icon(Icons.play_arrow),
          title: context.strings.playLabel,
          onSelected: onPlay),
      if (state.hasGenres())
        MovieEntry(
            icon: const Icon(Icons.video_library_outlined),
            title: context.strings.genresLabel,
            onSelected: onGenres),
      if (state.hasRelated())
        MovieEntry(
            icon: const Icon(Icons.movie),
            title: context.strings.relatedLabel,
            onSelected: onRelated),
      if (state.hasStarring())
        MovieEntry(
          icon: const Icon(Icons.people),
          title: context.strings.starringLabel,
          onSelected: onStarring),
    ];
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: RotaryList<MovieEntry>(entries,
                title: state.movie.title,
                subtitle:
                    '${Duration(minutes: state.movie.runtime).inHoursMinutes} \u2022 ${parseYear(state.movie.date)}',
                tileBuilder: (context, entry) =>
                    movieTile(context, entry, state))));
  }

  Widget movieTile(BuildContext context, MovieEntry entry, MovieView state) {
    final enableStreaming = allowStreaming(context);
    final title = entry.title;
    final subtitle = entry.subtitle;
    return ListTile(
        enabled: enableStreaming,
        leading: entry.icon,
        title: title != null ? Text(title) : null,
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: () => entry.onSelected?.call(context, state));
  }

  void onPlay(BuildContext context, MovieView state) {
    Navigator.push(context,
        CupertinoPageRoute<void>(builder: (_) => VideoPlayerPage(state)));
  }

  void onResume(BuildContext context, MovieView state) {
    final offset = context.offsets.state.get(state.movie);
    final startOffset =
        offset != null ? Duration(seconds: offset.offset) : null;
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (_) => VideoPlayerPage(state, startOffset: startOffset)));
  }

  void onGenres(BuildContext context, MovieView state) {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (_) => GenresPage(state.genres ?? [])));
  }

  void onRelated(BuildContext context, MovieView state) {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (_) => MoviesPage(
                context.strings.relatedLabel, state.relatedMovies())));
  }

  void onStarring(BuildContext context, MovieView state) {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (_) => PeoplePage(
                context.strings.starringLabel, state.starringPeople())));
  }
}

class MoviesPage extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MoviesPage(this.title, this.movies, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RotaryList<Movie>(movies, title: title, tileBuilder: movieTile));
  }

  Widget movieTile(BuildContext context, Movie movie) {
    return ListTile(
        leading: const Icon(Icons.movie),
        title: Text(movie.title),
        subtitle: Text('${parseYear(movie.date)}'),
        onTap: () => onMovie(context, movie));
  }

  void onMovie(BuildContext context, Movie movie) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => MoviePage(movie)));
  }
}

class VideoPlayerPage extends StatelessWidget {
  final MovieView state;
  final Duration? startOffset;

  const VideoPlayerPage(this.state, {this.startOffset, super.key});

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(
      state,
      startOffset: startOffset,
      mediaTrackResolver: context.read<MediaTrackResolver>(),
      tokenRepository: context.read<TokenRepository>(),
      settingsRepository: context.read<SettingsRepository>(),
      onPause: (position, duration) => onPause(context, position, duration),
    );
  }

  void onPause(BuildContext context, Duration position, Duration duration) {
    context.updateProgress(state.movie.etag,
        position: position, duration: duration);
  }
}

class GenresPage extends StatelessWidget {
  final List<String> genres;

  const GenresPage(this.genres, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RotaryList<String>(genres,
            title: context.strings.genresLabel, tileBuilder: genreTile));
  }

  Widget genreTile(BuildContext context, String genre) {
    return ListTile(
        leading: const Icon(Icons.video_library_outlined),
        title: Text(genre),
        onTap: () => onGenre(context, genre));
  }

  void onGenre(BuildContext context, String genre) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => GenrePage(genre)));
  }
}

class GenrePage extends ClientPage<GenreView> {
  final String genre;

  GenrePage(this.genre, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.moviesGenre(genre, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, GenreView state) {
    return MoviesPage(genre, state.movies);
  }
}

void _onMovie(BuildContext context, Movie movie) {
  Navigator.push(
      context, CupertinoPageRoute<void>(builder: (_) => MoviePage(movie)));
}

void _onDownload(BuildContext context, Movie movie) {
  if (allowDownload(context)) {
    confirmDialog(context,
            title: context.strings.confirmDownload, body: movie.title)
        .then((confirmed) {
      if (confirmed != null && confirmed) {
        final context = globalAppKey.currentContext;
        if (context != null && context.mounted) {
          context.downloadMovie(movie);
        }
      }
    });
  }
}

class PeoplePage extends StatelessWidget {
  final String title;
  final List<Person> people;

  const PeoplePage(this.title, this.people, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RotaryList<Person>(people,
            title: title, tileBuilder: personTile));
  }

  Widget personTile(BuildContext context, Person person) {
    return ListTile(
        leading: const Icon(Icons.person),
        title: Text(person.name),
        onTap: () => onPerson(context, person));
  }

  void onPerson(BuildContext context, Person person) {
    Navigator.push(
        context, CupertinoPageRoute<void>(builder: (_) => ProfilePage(person)));
  }
}

class ProfilePage extends ClientPage<ProfileView> {
  final Person person;

  ProfilePage(this.person, {super.key});

  @override
  void load(BuildContext context, {Duration? ttl}) {
    context.client.profile(person.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, ProfileView state) {
    final movies = <Movie>[];
    if (state.movies.starring.isNotEmpty) {
      movies.addAll(state.movies.starring);
    }
    return MediaPage(movies,
        title: state.person.name,
        onLongPress: (context, entry) => _onDownload(context, entry as Movie),
        onTap: (context, entry) => _onMovie(context, entry as Movie));
  }
}
