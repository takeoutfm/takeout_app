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

import 'package:bloc/bloc.dart';
import 'package:takeout_lib/api/client.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/stats.dart';

import 'repository.dart';

class ClientState {}

class ClientReady extends ClientState {}

class ClientLoading extends ClientState {}

class ClientError extends ClientState {
  final Object? error;
  final StackTrace? stackTrace;

  ClientError(this.error, this.stackTrace);
}

class ClientAuthError extends ClientError {
  final int statusCode;

  ClientAuthError(this.statusCode, super.error, super.stackTrace);
}

class ClientResult<T> extends ClientState {
  final T result;

  ClientResult(this.result);
}

typedef ClientRequest<T> = Future<T> Function({Duration? ttl});

class ClientCubit extends Cubit<ClientState> {
  final ClientRepository repository;
  final Duration _timeout;

  ClientCubit(this.repository, {Duration? timeout})
    : _timeout = timeout ?? const Duration(seconds: 10),
      super(ClientReady());

  void result<T>(T v) {
    emit(ClientResult<T>(v));
  }

  Future<void> login(String user, String password, {String? passcode}) =>
      _doit<bool>(
        ({Duration? ttl}) =>
            repository.login(user, password, passcode: passcode),
        ttl: Duration.zero,
      );

  Future<void> link({
    required String code,
    required String user,
    required String password,
    String? passcode,
  }) => _doit<bool>(
    ({Duration? ttl}) => repository.link(
      code: code,
      user: user,
      password: password,
      passcode: passcode,
    ),
    ttl: Duration.zero,
  );

  Future<void> code() => _doit<AccessCode>(
    ({Duration? ttl}) => repository.code(),
    ttl: Duration.zero,
  );

  Future<void> checkCode(AccessCode accessCode) => _doit<bool>(
    ({Duration? ttl}) => repository.checkCode(accessCode),
    ttl: Duration.zero,
  );

  Future<void> artists({Duration? ttl}) => _doit<ArtistsView>(
    ({Duration? ttl}) => repository.artists(ttl: ttl),
    ttl: ttl,
  );

  Future<void> artist(int id, {Duration? ttl}) => _doit<ArtistView>(
    ({Duration? ttl}) => repository.artist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistPlaylist(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.artistPlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistPopular(int id, {Duration? ttl}) => _doit<PopularView>(
    ({Duration? ttl}) => repository.artistPopular(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistPopularPlaylist(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.artistPopularPlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistSingles(int id, {Duration? ttl}) => _doit<SinglesView>(
    ({Duration? ttl}) => repository.artistSingles(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistSinglesPlaylist(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.artistSinglesPlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistRadio(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.artistRadio(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> artistWantList(int id, {Duration? ttl}) => _doit<WantListView>(
    ({Duration? ttl}) => repository.artistWantList(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> movie(int id, {Duration? ttl}) => _doit<MovieView>(
    ({Duration? ttl}) => repository.movie(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> moviePlaylist(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.moviePlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> movies({Duration? ttl}) => _doit<MoviesView>(
    ({Duration? ttl}) => repository.movies(ttl: ttl),
    ttl: ttl,
  );

  Future<void> moviesGenre(String genre, {Duration? ttl}) => _doit<GenreView>(
    ({Duration? ttl}) => repository.moviesGenre(genre, ttl: ttl),
    ttl: ttl,
  );

  Future<void> shows({Duration? ttl}) => _doit<TVShowsView>(
    ({Duration? ttl}) => repository.shows(ttl: ttl),
    ttl: ttl,
  );

  Future<void> tvList({Duration? ttl}) => _doit<TVListView>(
    ({Duration? ttl}) => repository.tvList(ttl: ttl),
    ttl: ttl,
  );

  Future<void> tvSeries(int id, {Duration? ttl}) => _doit<TVSeriesView>(
    ({Duration? ttl}) => repository.tvSeries(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> tvEpisode(int id, {Duration? ttl}) => _doit<TVEpisodeView>(
    ({Duration? ttl}) => repository.tvEpisode(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> profile(int peid, {Duration? ttl}) => _doit<ProfileView>(
    ({Duration? ttl}) => repository.profile(peid, ttl: ttl),
    ttl: ttl,
  );

  Future<void> radio({Duration? ttl}) => _doit<RadioView>(
    ({Duration? ttl}) => repository.radio(ttl: ttl),
    ttl: ttl,
  );

  Future<void> release(int id, {Duration? ttl}) => _doit<ReleaseView>(
    ({Duration? ttl}) => repository.release(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> releasePlaylist(String id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.releasePlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> trackPlaylist(String id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.trackPlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> search(String query, {Duration? ttl}) => _doit<SearchView>(
    ({Duration? ttl}) => repository.search(query, ttl: ttl),
    ttl: ttl,
  );

  Future<void> series(int id, {Duration? ttl}) => _doit<SeriesView>(
    ({Duration? ttl}) => repository.series(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> seriesSubscribe(int id) =>
      _doit<void>(({Duration? ttl}) => repository.seriesSubscribe(id));

  Future<void> seriesUnsubscribe(int id) =>
      _doit<void>(({Duration? ttl}) => repository.seriesUnsubscribe(id));

  Future<void> seriesPlaylist(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.seriesPlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> episodePlaylist(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.episodePlaylist(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> station(int id, {Duration? ttl}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.station(id, ttl: ttl),
    ttl: ttl,
  );

  Future<void> index({Duration? ttl}) => _doit<IndexView>(
    ({Duration? ttl}) => repository.index(ttl: ttl),
    ttl: ttl,
  );

  Future<void> home({Duration? ttl}) =>
      _doit<HomeView>(({Duration? ttl}) => repository.home(ttl: ttl), ttl: ttl);

  Future<void> recentTracks({Duration? ttl}) => _doit<TrackHistoryView>(
    ({Duration? ttl}) => repository.recentTracks(ttl: ttl),
    ttl: ttl,
  );

  Future<void> popularTracks({Duration? ttl}) => _doit<TrackStatsView>(
    ({Duration? ttl}) => repository.popularTracks(ttl: ttl),
    ttl: ttl,
  );

  Future<void> patch(List<Map<String, dynamic>> body) =>
      _doit<PatchResult>(({Duration? ttl}) => repository.patch(body));

  Future<void> playlist({Duration? ttl, int? id}) => _doit<Spiff>(
    ({Duration? ttl}) => repository.playlist(ttl: ttl, id: id),
    ttl: ttl,
  );

  Future<void> playlists({Duration? ttl}) => _doit<PlaylistsView>(
    ({Duration? ttl}) => repository.playlists(ttl: ttl),
    ttl: ttl,
  );

  Future<void> createPlaylist(Spiff spiff) => _doit2<PlaylistsView>(
    ({Duration? ttl}) => repository.createPlaylist(spiff),
    ({Duration? ttl}) => repository.playlists(ttl: Duration.zero),
  );

  Future<void> deletePlaylist(PlaylistView playlist) => _doit2<PlaylistsView>(
    ({Duration? ttl}) => repository.deletePlaylist(playlist),
    ({Duration? ttl}) => repository.playlists(ttl: Duration.zero),
  );

  Future<void> playlistAppend(PlaylistView playlist, String ref) async {
    await repository.playlistAppend(playlist, ref);
  }

  Future<void> progress({Duration? ttl}) => _doit<ProgressView>(
    ({Duration? ttl}) => repository.progress(ttl: ttl),
    ttl: ttl,
  );

  Future<void> updateProgress(Offsets offsets) =>
      _doit<int>(({Duration? ttl}) => repository.updateProgress(offsets));

  Future<void> trackStats({Duration? ttl, IntervalType? interval}) =>
      _doit<TrackStatsView>(
        ({Duration? ttl}) =>
            repository.trackStats(ttl: ttl, interval: interval),
        ttl: ttl,
      );

  Future<void> updateActivity(Events events) =>
      _doit<int>(({Duration? ttl}) => repository.updateActivity(events));

  Future<void> podcasts({Duration? ttl}) => _doit<PodcastsView>(
    ({Duration? ttl}) => repository.podcasts(ttl: ttl),
    ttl: ttl,
  );

  Future<void> podcastsSubscribed({Duration? ttl}) => _doit<PodcastsView>(
    ({Duration? ttl}) => repository.podcastsSubscribed(ttl: ttl),
    ttl: ttl,
  );

  Future<void> _doit<T>(ClientRequest<T> call, {Duration? ttl}) async {
    emit(ClientLoading());
    return call(ttl: ttl)
        .timeout(_timeout)
        .then((T result) => emit(ClientResult<T>(result)))
        .onError(_handleError);
  }

  // call1 must be idempotent since it may be called again if call2 fails.
  Future<void> _doit2<T>(
    ClientRequest<dynamic> call1,
    ClientRequest<T> call2, {
    Duration? ttl,
  }) async {
    emit(ClientLoading());
    return call1(ttl: ttl)
        .timeout(_timeout)
        .then(
          (_) => call2(ttl: ttl)
              .timeout(_timeout)
              .then((T result) => emit(ClientResult<T>(result)))
              .onError(_handleError),
        )
        .onError(_handleError);
  }

  // timeouts will be raised here as a TimeoutException and emitted as ClientError
  void _handleError(Object? error, StackTrace stackTrace) {
    if (error is ClientException && error.authenticationFailed) {
      emit(ClientAuthError(error.statusCode, error, stackTrace));
    } else {
      emit(ClientError(error, stackTrace));
    }
  }
}
