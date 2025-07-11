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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/art/scaffold.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/page/page.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/util.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'buttons.dart';
import 'nav.dart';
import 'people.dart';
import 'style.dart';

class MovieWidget extends ClientPage<MovieView> {
  final Movie _movie;

  MovieWidget(this._movie, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.movie(_movie.id, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, MovieView state) {
    return scaffold(context,
        image: _movie.image,
        body: (_) => RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: BlocBuilder<TrackCacheCubit, TrackCacheState>(
                builder: (context, cacheState) {
              final isCached = cacheState.contains(_movie);
              final screen = MediaQuery.of(context).size;
              final expandedHeight = screen.height / 2;
              return CustomScrollView(slivers: [
                SliverAppBar(
                  // actions: [ ],
                  backgroundColor: Colors.black,
                  expandedHeight: expandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                      // centerTitle: true,
                      // title: Text(release.name, style: TextStyle(fontSize: 15)),
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle
                      ],
                      background: Stack(fit: StackFit.expand, children: [
                        releaseSmallCover(context, _movie.image),
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
                            child: _playButton(context, state, isCached)),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: _progress(context)),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: _downloadButton(context, isCached)),
                      ])),
                ),
                SliverToBoxAdapter(
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                        child: Column(children: [
                          _title(context),
                          _tagline(context),
                          _details(context),
                          if (state.hasGenres()) _genres(context, state),
                          // GestureDetector(
                          //     onTap: () => _onArtist(), child: _title()),
                          // GestureDetector(
                          //     onTap: () => _onArtist(), child: _artist()),
                        ]))),
                if (state.hasCast())
                  SliverToBoxAdapter(child: heading(context.strings.castLabel)),
                if (state.hasCast())
                  SliverToBoxAdapter(child: CastListWidget(state.cast ?? [])),
                if (state.hasCrew())
                  SliverToBoxAdapter(child: heading(context.strings.crewLabel)),
                if (state.hasCrew())
                  SliverToBoxAdapter(child: CrewListWidget(state.crew ?? [])),
                if (state.hasRelated())
                  SliverToBoxAdapter(
                    child: heading(context.strings.relatedLabel),
                  ),
                if (state.hasRelated()) MovieGridWidget(state.other!),
              ]);
            })));
  }

  Widget _progress(BuildContext context) {
    final value = context.offsets.state.value(_movie);
    // print('progress for ${_movie.etag} is $value');
    return value != null
        ? LinearProgressIndicator(value: value)
        : const EmptyWidget();
  }

  Widget _title(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Text(_movie.title,
            style: Theme.of(context).textTheme.headlineSmall));
  }

  Widget _rating(BuildContext context) {
    final boxColor = Theme.of(context).textTheme.bodyLarge?.color ??
        Theme.of(context).colorScheme.outline;
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(border: Border.all(color: boxColor)),
      child: Text(_movie.rating),
    );
  }

  Widget _details(BuildContext context) {
    var list = <Widget>[];
    if (_movie.rating.isNotEmpty) {
      list.add(_rating(context));
    }

    final fields = <String>[];

    // runtime
    if (_movie.runtime > 0) {
      fields.add(Duration(minutes: _movie.runtime).inHoursMinutes);
    }

    // year
    if (_movie.year > 1) {
      fields.add(_movie.year.toString());
    }

    // vote%
    fields.add(_movie.vote);

    // storage
    fields.add(storage(_movie.size));

    list.add(
        Text(merge(fields), style: Theme.of(context).textTheme.titleSmall));

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget _tagline(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Text(_movie.tagline,
            style: Theme.of(context).textTheme.titleMedium!));
  }

  Widget _genres(BuildContext context, MovieView view) {
    return Center(
        child: Wrap(
            direction: Axis.horizontal,
            spacing: 8.0,
            runSpacing: 8.0,
            // runAlignment: WrapAlignment.spaceEvenly,
            children: [
          ...view.genres!.map((g) => OutlinedButton(
              onPressed: () => _onGenre(context, g), child: Text(g)))
        ]));
  }

  Widget _playButton(BuildContext context, MovieView view, bool isCached) {
    final offsetCache = context.offsets;
    final pos = offsetCache.state.position(_movie) ?? Duration.zero;
    return isCached
        ? IconButton(
            icon: const Icon(Icons.play_arrow, size: 32),
            onPressed: () => _onPlay(context, view, pos))
        : StreamingButton(onPressed: () => _onPlay(context, view, pos));
  }

  Widget _downloadButton(BuildContext context, bool isCached) {
    // TODO show download progress
    return isCached
        ? IconButton(icon: const Icon(iconsDownloadDone), onPressed: () => {})
        : DownloadButton(onPressed: () => _onDownload(context));
  }

  void _onPlay(BuildContext context, MovieView view, Duration startOffset) {
    playMovie(context, MovieMediaTrack(view), startOffset: startOffset);
  }

  void _onDownload(BuildContext context) {
    context.downloadMovie(_movie);
  }

  void _onGenre(BuildContext context, String genre) {
    push(context, builder: (_) => GenreWidget(genre));
  }
}

class GenreWidget extends ClientPage<GenreView> {
  final String _genre;

  GenreWidget(this._genre, {super.key});

  @override
  Future<void> load(BuildContext context, {Duration? ttl}) {
    return context.client.moviesGenre(_genre, ttl: ttl);
  }

  @override
  Widget page(BuildContext context, GenreView state) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: () => reloadPage(context),
            child: CustomScrollView(slivers: [
              SliverAppBar(title: Text(_genre)),
              if (state.movies.isNotEmpty)
                MovieGridWidget(_sortByTitle(state.movies)),
            ])));
  }
}

class MovieGridWidget extends StatelessWidget {
  final List<Movie> _movies;

  const MovieGridWidget(this._movies, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.extent(
        maxCrossAxisExtent: posterGridWidth,
        childAspectRatio: posterAspectRatio,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: [
          ..._movies.map((m) => GestureDetector(
              onTap: () => _onTap(context, m),
              child: GridTile(
                footer: const Material(
                    color: Colors.transparent,
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.vertical(
                    //         bottom: Radius.circular(4))),
                    clipBehavior: Clip.antiAlias,
                    child: GridTileBar(
                      backgroundColor: Colors.black26,
                      // title: Text('${m.rating}'),
                      // trailing: Text('${m.year}'),
                    )),
                child: gridPoster(context, m.image),
              )))
        ]);
  }

  void _onTap(BuildContext context, Movie movie) {
    push(context, builder: (_) => MovieWidget(movie));
  }
}

enum MovieState { buffering, playing, paused, none }

class MoviePlayer extends StatefulWidget {
  final MediaTrack movie;
  final Duration? startOffset;
  final MediaTrackResolver mediaTrackResolver;
  final SettingsRepository settingsRepository;
  final TokenRepository tokenRepository;

  const MoviePlayer(this.movie,
      {super.key,
      required this.mediaTrackResolver,
      required this.settingsRepository,
      required this.tokenRepository,
      this.startOffset = Duration.zero});

  @override
  MoviePlayerState createState() => MoviePlayerState();
}

// TODO add location back to movie to avoid this hassle?
class MovieMediaTrack implements MediaTrack {
  MovieView view;

  MovieMediaTrack(this.view);

  @override
  String get creator => '';

  @override
  String get album => '';

  @override
  String get image => view.movie.image;

  @override
  int get year => 0;

  @override
  String get title => view.movie.title;

  @override
  String get etag => view.movie.etag;

  @override
  int get size => view.movie.size;

  @override
  int get number => 0;

  @override
  int get disc => 0;

  @override
  String get date => view.movie.date;

  @override
  String get location => view.location;
}

class MoviePlayerState extends State<MoviePlayer> {
  late final _stateStream = BehaviorSubject<MovieState>();
  late final _positionStream = BehaviorSubject<Duration>();
  VideoPlayerController? _controller;
  VideoProgressIndicator? _progress;
  StreamSubscription<MovieState>? _stateSubscription;
  var _showControls = false;
  var _videoInitialized = false;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    prepareController();
  }

  Future<void> prepareController() async {
    // controller
    final uri = await widget.mediaTrackResolver.resolve(widget.movie);
    String url = uri.toString();
    if (url.startsWith('/api/')) {
      url = '${widget.settingsRepository.settings?.endpoint}$url';
    }
    final headers = widget.tokenRepository.addMediaToken();
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(url), httpHeaders: headers);
    // TODO not sure what this does
    unawaited(controller.initialize().then((_) => setState(() {})));
    // progress
    _progress = VideoProgressIndicator(controller,
        colors: const VideoProgressColors(
            playedColor: Colors.orangeAccent, bufferedColor: Colors.green),
        allowScrubbing: true,
        padding: const EdgeInsets.all(32));
    // events
    controller.addListener(() {
      final value = controller.value;
      if (_videoInitialized == false && value.isInitialized) {
        _videoInitialized = true;
        if (widget.startOffset != null) {
          controller.seekTo(widget.startOffset!);
        }
        controller.play(); // autoplay
      }
      if (value.isPlaying) {
        _stateStream.add(MovieState.playing);
      } else if (value.isBuffering) {
        _stateStream.add(MovieState.buffering);
      } else if (value.isPlaying == false) {
        _stateStream.add(MovieState.paused);
      }
      _positionStream.add(value.position);
    });
    _stateSubscription = _stateStream.distinct().listen((state) {
      switch (state) {
        case MovieState.playing:
          WakelockPlus.enable();
          _controlsTimer?.cancel();
          _controlsTimer = Timer(const Duration(seconds: 2), () {
            showControls(false);
          });
        default:
          WakelockPlus.disable();
          _controlsTimer?.cancel();
          showControls(true);
      }
    });

    setState(() {
      _controller = controller;
    });
  }

  void toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void showControls(bool show) {
    setState(() {
      _showControls = show;
    });
  }

  String _pos(Duration pos) {
    return '${pos.hhmmss} ~ ${(_controller?.value.duration ?? Duration.zero).hhmmss}';
  }

  void _saveState(BuildContext context) {
    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration;
    context.updateProgress(widget.movie.etag,
        position: position, duration: duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onTap: () {
            if (_stateStream.value == MovieState.playing) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              toggleControls();
            }
          },
          child: _controller == null
              ? const EmptyWidget()
              : Center(
                  child: _controller!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              VideoPlayer(_controller!),
                              if (_showControls) _progress!,
                              if (_showControls)
                                StreamBuilder<Duration>(
                                    stream: _positionStream,
                                    builder: (context, snapshot) {
                                      final duration = snapshot.data;
                                      return Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                              padding: const EdgeInsets.all(3),
                                              child: Text(duration != null
                                                  ? _pos(duration)
                                                  : '')));
                                    }),
                              if (_showControls)
                                StreamBuilder<MovieState>(
                                    stream: _stateStream.distinct(),
                                    builder: (context, snapshot) {
                                      final state =
                                          snapshot.data ?? MovieState.none;
                                      return state == MovieState.none
                                          ? const EmptyWidget()
                                          : Center(
                                              child: IconButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  onPressed: () {
                                                    if (state ==
                                                        MovieState.playing) {
                                                      _controller!.pause();
                                                      _saveState(context);
                                                    } else {
                                                      _controller!.play();
                                                    }
                                                  },
                                                  icon: Icon(
                                                      state ==
                                                              MovieState.playing
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      size: 64)));
                                    })
                            ],
                          ))
                      : const EmptyWidget(),
                )),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
    _controller?.dispose();
    _stateSubscription?.cancel();
  }
}

class MovieListWidget extends StatelessWidget {
  final List<Movie> _movies;

  const MovieListWidget(this._movies, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ..._movies.asMap().keys.toList().map((index) => ListTile(
          onTap: () => _onTapped(context, _movies[index]),
          leading: tilePoster(context, _movies[index].image),
          subtitle: Text(
              merge([_movies[index].year.toString(), _movies[index].rating])),
          title: Text(_movies[index].title)))
    ]);
  }

  void _onTapped(BuildContext context, Movie movie) {
    push(context, builder: (_) => MovieWidget(movie));
  }
}

void playMovie(BuildContext context, MediaTrack movie,
    {Duration? startOffset}) {
  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (_) => MoviePlayer(movie,
          settingsRepository: context.read<SettingsRepository>(),
          tokenRepository: context.read<TokenRepository>(),
          mediaTrackResolver: context.read<MediaTrackResolver>(),
          startOffset: startOffset)));
}

// Note this modifies the original list.
List<Movie> _sortByTitle(List<Movie> movies) {
  movies.sort((a, b) => a.sortTitle.compareTo(b.sortTitle));
  return movies;
}
