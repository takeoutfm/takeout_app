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

import 'dart:io';

import 'package:http/http.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/spiff/model.dart';
import 'package:takeout_lib/stats/stats.dart';

abstract class ClientProvider {
  Client get client;

  Future<bool> login(String user, String password, {String? passcode});

  Future<bool> link({
    required String code,
    required String user,
    required String password,
    String? passcode,
  });

  Future<AccessCode> code();

  Future<bool> checkCode(AccessCode accessCode);

  Future<ArtistsView> artists({Duration? ttl});

  Future<ArtistView> artist(int id, {Duration? ttl});

  Future<Spiff> artistRadio(int id, {Duration? ttl});

  Future<Spiff> artistPlaylist(int id, {Duration? ttl});

  Future<PopularView> artistPopular(int id, {Duration? ttl});

  Future<Spiff> artistPopularPlaylist(int id, {Duration? ttl});

  Future<SinglesView> artistSingles(int id, {Duration? ttl});

  Future<Spiff> artistSinglesPlaylist(int id, {Duration? ttl});

  Future<WantListView> artistWantList(int id, {Duration? ttl});

  Future<SearchView> search(String q, {Duration? ttl = Duration.zero});

  Future<Spiff> station(int id, {Duration? ttl = Duration.zero});

  Future<IndexView> index({Duration? ttl});

  Future<HomeView> home({Duration? ttl});

  Future<MovieView> movie(int id, {Duration? ttl});

  Future<Spiff> moviePlaylist(int id, {Duration? ttl});

  Future<GenreView> moviesGenre(String genre, {Duration? ttl});

  Future<MoviesView> movies({Duration? ttl});

  Future<TVShowsView> shows({Duration? ttl});

  Future<TVListView> tvList({Duration? ttl});

  Future<TVSeriesView> tvSeries(int id, {Duration? ttl});

  Future<Spiff> tvSeriesPlaylist(int id, {Duration? ttl});

  Future<TVEpisodeView> tvEpisode(int id, {Duration? ttl});

  Future<Spiff> tvEpisodePlaylist(int id, {Duration? ttl});

  Future<ProfileView> profile(int peid, {Duration? ttl});

  Future<RadioView> radio({Duration? ttl});

  Future<ReleaseView> release(int id, {Duration? ttl});

  Future<Spiff> releasePlaylist(String id, {Duration? ttl});

  Future<Spiff> trackPlaylist(String id, {Duration? ttl});

  Future<SeriesView> series(int id, {Duration? ttl});

  Future<void> seriesSubscribe(int id);

  Future<void> seriesUnsubscribe(int id);

  Future<Spiff> seriesPlaylist(int id, {Duration? ttl});

  Future<Spiff> episodePlaylist(int id, {Duration? ttl});

  Future<TrackHistoryView> recentTracks({Duration? ttl});

  Future<Spiff> recentTracksPlaylist({Duration? ttl});

  Future<TrackStatsView> popularTracks({Duration? ttl});

  Future<Spiff> popularTracksPlaylist({Duration? ttl});

  Future<int> download(Uri uri, File file, int size, {Sink<int>? progress});

  Future<PatchResult> patch(List<Map<String, dynamic>> body);

  Future<Spiff> playlist({Duration? ttl, int? id, String? name});

  Future<PlaylistsView> playlists({Duration? ttl});

  Future<PlaylistView> createPlaylist(Spiff spiff);

  Future<PatchResult> patchPlaylist(
    PlaylistView playlist,
    List<Map<String, dynamic>> body,
  );

  Future<void> deletePlaylist(PlaylistView playlist);

  Future<ProgressView> progress({Duration? ttl});

  Future<int> updateProgress(Offsets offsets);

  Future<TrackStatsView> trackStats({Duration? ttl, IntervalType? interval});

  Future<int> updateActivity(Events events);

  Future<PodcastsView> podcasts({Duration? ttl});

  Future<PodcastsView> podcastsSubscribed({Duration? ttl});
}
