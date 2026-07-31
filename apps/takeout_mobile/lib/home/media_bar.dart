import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/home/menu.dart';
import 'package:takeout_mobile/pages/search/search_results.dart';

class MediaActions {
  List<Widget> call(BuildContext context) {
    final index = context.read<IndexCubit>().state;
    final mediaType = context.read<MediaTypeCubit>().state.mediaType;

    const iconSize = 22.0;
    final buttons = SplayTreeMap<MediaType, Widget>(
      (a, b) => a.index.compareTo(b.index),
    );

    final style = IconButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      minimumSize: const Size(36, 36),
    );

    if (index.music) {
      buttons[MediaType.music] = IconButton(
        iconSize: iconSize,
        style: style,
        icon: mediaType == MediaType.music
            ? const Icon(Icons.speaker)
            : const Icon(Icons.speaker_outlined),
        onPressed: () => _onMusicSelected(context),
      );
    }
    if (index.movies) {
      buttons[MediaType.film] = IconButton(
        iconSize: iconSize,
        style: style,
        icon: mediaType == MediaType.film
            ? const Icon(Icons.movie)
            : const Icon(Icons.movie_outlined),
        onPressed: () => _onFilmSelected(context),
      );
    }
    if (index.shows) {
      buttons[MediaType.tv] = IconButton(
        iconSize: iconSize,
        style: style,
        icon: mediaType == MediaType.tv
            ? const Icon(Icons.tv)
            : const Icon(Icons.tv_outlined),
        onPressed: () => _onTVSelected(context),
      );
    }
    if (index.podcasts) {
      buttons[MediaType.podcast] = IconButton(
        iconSize: iconSize,
        style: style,
        icon: mediaType == MediaType.podcast
            ? const Icon(Icons.podcasts)
            : const Icon(Icons.podcasts_outlined),
        onPressed: () => _onPodcastsSelected(context),
      );
    }
    final iconBar = <Widget>[];
    iconBar.addAll(buttons.values);

    return [...iconBar, HomeMenu()];
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

class SliverMediaBar extends StatefulWidget {
  const SliverMediaBar({super.key});

  @override
  SliverMediaState createState() => SliverMediaState();
}

class SliverMediaState extends State<SliverMediaBar> {
  final TextEditingController _controller = TextEditingController();

  // List<String> _suggestions = [];
  // bool _showSuggestions = false;

  @override
  Widget build(BuildContext context) {
    context.watch<IndexCubit>().state;
    context.watch<MediaTypeCubit>().state.mediaType;
    final actions = MediaActions();
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      // titleSpacing: 0,
      title: SearchBar(
        controller: _controller,
        constraints: const BoxConstraints(
          minHeight: 40,
          maxWidth: double.infinity,
        ),
        hintText: 'Search',
        leading: const Icon(Icons.search),
        trailing: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
              },
            ),
        ],
        onSubmitted: (query) => _onSearch(query),
      ),
      actionsPadding: EdgeInsets.zero,
      actionsIconTheme: const IconThemeData(size: 22),
      actions: actions(context),
    );
  }

  // void _onChanged(String query) {
  //   setState(() {
  //     if (query.trim().isEmpty) {
  //       _showSuggestions = false;
  //       _suggestions = [];
  //     } else {
  //       _suggestions = _allItems
  //           .where((s) => s.toLowerCase().contains(query.toLowerCase()))
  //           .take(8)
  //           .toList();
  //       _showSuggestions = _suggestions.isNotEmpty;
  //     }
  //   });
  // }

  void _onSearch(String query) {
    query = query.trim();
    if (query.isEmpty) {
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => SearchResults(query)));
  }
}
