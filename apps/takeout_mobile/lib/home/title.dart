import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/context.dart';

class NavTitleWidget extends StatelessWidget {
  const NavTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final mediaType = context.watch<MediaTypeCubit>().state.mediaType;
    final title = switch (state.navigationIndex) {
      .music => context.strings.navMusic,
      .artists => context.strings.navArtists,
      .radio => context.strings.navRadio,
      .film => context.strings.navMovies,
      .tv => context.strings.navTVShows,
      .podcast => context.strings.navPodcasts,
      .history => context.strings.navHistory,
      .player => context.strings.navPlayer,
      .search => context.strings.navSearch,
      .home => switch (mediaType) {
        .music => context.strings.navMusic,
        .podcast => context.strings.navPodcasts,
        .film => context.strings.navMovies,
        .tv => context.strings.navTVShows,
        _ => 'Takeout',
      },
    };
    return Text(title);
  }
}
