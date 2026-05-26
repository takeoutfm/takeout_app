import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/pages/search.dart';
import 'package:takeout_mobile/home/menu.dart';

class MediaActions {
  List<Widget> call(BuildContext context) {
    final index = context.read<IndexCubit>().state;
    final mediaType = context.read<MediaTypeCubit>().state.mediaType;

    const iconSize = 22.0;
    final buttons = SplayTreeMap<MediaType, Widget>(
          (a, b) => a.index.compareTo(b.index),
    );
    if (index.music) {
      buttons[MediaType.music] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.music
            ? const Icon(Icons.audiotrack)
            : const Icon(Icons.audiotrack_outlined),
        onPressed: () => _onMusicSelected(context),
      );
    }
    if (index.movies) {
      buttons[MediaType.film] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.film
            ? const Icon(Icons.movie)
            : const Icon(Icons.movie_outlined),
        onPressed: () => _onFilmSelected(context),
      );
    }
    if (index.shows) {
      buttons[MediaType.tv] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.tv
            ? const Icon(Icons.tv)
            : const Icon(Icons.tv_outlined),
        onPressed: () => _onTVSelected(context),
      );
    }
    if (index.podcasts) {
      buttons[MediaType.podcast] = IconButton(
        iconSize: iconSize,
        icon: mediaType == MediaType.podcast
            ? const Icon(Icons.podcasts)
            : const Icon(Icons.podcasts_outlined),
        onPressed: () => _onPodcastsSelected(context),
      );
    }
    final iconBar = <Widget>[];
    iconBar.addAll(buttons.values);

    return [
        ...iconBar,
       HomeMenu(),
    ];
  }

  void _onFilmSelected(BuildContext context) {
    context.app.home();
    if (context.selectedMediaType.state.isFilm()) {
      context.selectedMediaType.nextFilmType();
    } else {
      context.selectedMediaType.select(MediaType.film);
    }
  }

  void _onTVSelected(BuildContext context) {
    context.app.home();
    // TODO no subtypes yet
    context.selectedMediaType.select(MediaType.tv);
  }

  void _onMusicSelected(BuildContext context) {
    context.app.home();
    if (context.selectedMediaType.state.isMusic()) {
      context.selectedMediaType.nextMusicType();
    } else {
      context.selectedMediaType.select(MediaType.music);
    }
  }

  void _onPodcastsSelected(BuildContext context) {
    context.app.home();
    if (context.selectedMediaType.state.isPodcast()) {
      context.selectedMediaType.nextPodcastType();
    } else {
      context.selectedMediaType.select(MediaType.podcast);
    }
  }
}

class SliverMediaBar extends StatelessWidget {
  const SliverMediaBar({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<IndexCubit>().state;
    context.watch<MediaTypeCubit>().state.mediaType;
    final actions = MediaActions();
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => _onSearch(context),
      ),
      actions: actions(context),
    );
  }

  void _onSearch(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => SearchWidget()));
}
