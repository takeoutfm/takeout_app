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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/provider.dart';
import 'package:takeout_lib/browser/repository.dart';
import 'package:takeout_lib/cache/offset.dart';
import 'package:takeout_lib/cache/spiff.dart';
import 'package:takeout_lib/cache/track.dart';
import 'package:takeout_lib/client/client.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_lib/db/search.dart';
import 'package:takeout_lib/history/history.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_lib/listen/repository.dart';
import 'package:takeout_lib/media_type/media_type.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_lib/player/playing.dart';
import 'package:takeout_lib/player/playlist.dart';
import 'package:takeout_lib/settings/settings.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/repository.dart';
import 'package:takeout_lib/stats/stats.dart';
import 'package:takeout_lib/subscribed/subscribed.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/tokens/tokens.dart';

extension TakeoutContext on BuildContext {
  void play(Spiff spiff, {bool? autoPlay, bool? autoCache}) {
    autoPlay ??= settings.state.settings.autoPlay;
    autoCache ??= settings.state.settings.autoCache;
    nowPlaying.add(spiff, autoPlay: autoPlay, autoCache: autoCache);
  }

  void stream(int station) {
    clientRepository
        .station(station, ttl: Duration.zero)
        .then((spiff) => play(spiff));
  }

  void download(Spiff spiff) {
    spiffCache.add(spiff);
    final events = spiff.playlist.tracks.map(
      (t) => DownloadEvent(t, Uri.parse(t.location), t.size),
    );
    downloads.addAll(events);
  }

  void remove(Spiff spiff) {
    trackCache.removeIds(spiff.playlist.tracks);
    spiffCache.remove(spiff);
  }

  void downloadRelease(Release release) {
    clientRepository
        .releasePlaylist('${release.id}')
        .then((spiff) => download(spiff));
  }

  void downloadTracks(Iterable<Track> tracks) {
    final events = tracks.map(
      (t) => DownloadEvent(t, Uri.parse(t.location), t.size),
    );
    downloads.addAll(events);
  }

  void downloadSeries(Series series) {
    clientRepository.seriesPlaylist(series.id).then((spiff) => download(spiff));
  }

  void downloadEpisode(Episode episode) {
    clientRepository
        .episodePlaylist(episode.id)
        .then((spiff) => download(spiff));
  }

  void downloadEpisodes(Iterable<Episode> episodes) {
    final events = episodes.map(
      (t) => DownloadEvent(t, Uri.parse(t.location), t.size),
    );
    downloads.addAll(events);
  }

  void downloadStation(Station station) {
    clientRepository
        .station(station.id, ttl: Duration.zero)
        .then((spiff) => download(spiff));
  }

  void downloadPlaylist(PlaylistView playlist) {
    clientRepository
        .playlist(id: playlist.id, ttl: Duration.zero)
        .then((spiff) => download(spiff));
  }

  void downloadMovie(Movie movie) {
    clientRepository.moviePlaylist(movie.id).then((spiff) => download(spiff));
  }

  void downloadTVEpisode(TVEpisode episode) {
    clientRepository
        .tvEpisodePlaylist(episode.id)
        .then((spiff) => download(spiff));
  }

  Future<void> reload() async {
    await index.reload();
    await search.reload();
    await offsets.reload();
  }

  void removeDownloads() {
    spiffCache.removeAll();
    trackCache.removeAll();
  }

  Future<void> updateProgress(
    String etag, {
    required Duration position,
    Duration? duration,
  }) async {
    final offset = Offset.now(etag: etag, offset: position, duration: duration);
    if (await offsets.repository.contains(offset) == false) {
      // add local offset
      await offsets.add(offset);
      // send to server
      await clientRepository.updateProgress(Offsets(offsets: [offset]));
    }
  }

  Future<void> updatePosition(int index, double position) async {
    await clientRepository.updatePosition(index, position);
  }

  ArtProvider get imageProvider => read<ArtProvider>();

  ClientCubit get client => read<ClientCubit>();

  ClientRepository get clientRepository => read<ClientRepository>();

  ConnectivityCubit get connectivity => read<ConnectivityCubit>();

  DownloadCubit get downloads => read<DownloadCubit>();

  HistoryCubit get history => read<HistoryCubit>();

  IndexCubit get index => read<IndexCubit>();

  MediaTrackResolver get resolver => read<MediaTrackResolver>();

  MediaTypeCubit get selectedMediaType => read<MediaTypeCubit>();

  NowPlayingCubit get nowPlaying => read<NowPlayingCubit>();

  OffsetCacheCubit get offsets => read<OffsetCacheCubit>();

  Player get player => read<Player>();

  PlaylistCubit get playlist => read<PlaylistCubit>();

  Search get search => read<Search>();

  SettingsCubit get settings => read<SettingsCubit>();

  SpiffCacheCubit get spiffCache => read<SpiffCacheCubit>();

  SubscribedCubit get subscribed => read<SubscribedCubit>();

  TokenRepository get tokenRepository => read<TokenRepository>();

  TokensCubit get tokens => read<TokensCubit>();

  TrackCacheCubit get trackCache => read<TrackCacheCubit>();

  MediaRepository get mediaRepository => read<MediaRepository>();

  ListenRepository get listenRepository => read<ListenRepository>();

  StatsCubit get stats => read<StatsCubit>();

  StatsRepository get statsRepository => read<StatsRepository>();

  bool get allowMobileDownload {
    return settings.state.settings.allowMobileDownload;
  }

  bool get allowMobileStreaming {
    return settings.state.settings.allowMobileStreaming;
  }

  bool get enableTrackActivity {
    return settings.state.settings.enableTrackActivity;
  }

  bool get enableListenBrainz {
    return settings.state.settings.enableListenBrainz;
  }
}
