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

import 'dart:core';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:takeout_lib/cache/offset_repository.dart';
import 'package:takeout_lib/client/download.dart';
import 'package:takeout_lib/client/etag.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/util.dart';

part 'model.g.dart';

class PostResult {
  final int statusCode;

  PostResult(this.statusCode);

  bool get noContent => statusCode == HttpStatus.noContent;

  bool get resetContent => statusCode == HttpStatus.resetContent;

  bool get clientError => statusCode == HttpStatus.badRequest;

  bool get serverError => statusCode == HttpStatus.internalServerError;
}

class PatchResult extends PostResult {
  final Map<String, dynamic> body;

  PatchResult(int statusCode, this.body) : super(statusCode);

  bool get isModified => statusCode == HttpStatus.ok;

  bool get notModified => noContent;
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Code {
  final String code;

  Code({required this.code});

  factory Code.fromJson(Map<String, dynamic> json) => _$CodeFromJson(json);

  Map<String, dynamic> toJson() => _$CodeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class AccessCode {
  final String code;
  final String accessToken;

  AccessCode({required this.code, required this.accessToken});

  factory AccessCode.fromJson(Map<String, dynamic> json) =>
      _$AccessCodeFromJson(json);

  Map<String, dynamic> toJson() => _$AccessCodeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class IndexView {
  final int time;
  final bool hasMusic;
  final bool hasMovies;
  final bool hasPodcasts;

  IndexView(
      {required this.time,
      required this.hasMusic,
      required this.hasMovies,
      required this.hasPodcasts});

  factory IndexView.fromJson(Map<String, dynamic> json) =>
      _$IndexViewFromJson(json);

  Map<String, dynamic> toJson() => _$IndexViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class HomeView {
  @JsonKey(name: 'AddedReleases')
  final List<Release> added;
  @JsonKey(name: 'NewReleases')
  final List<Release> released;
  final List<Movie> addedMovies;
  final List<Movie> newMovies;
  final List<Recommend>? recommendMovies;
  final List<Episode>? newEpisodes;
  final List<Series>? newSeries;

  HomeView(
      {this.added = const [],
      this.released = const [],
      this.addedMovies = const [],
      this.newMovies = const [],
      this.recommendMovies = const [],
      this.newEpisodes = const [],
      this.newSeries = const []});

  factory HomeView.fromJson(Map<String, dynamic> json) =>
      _$HomeViewFromJson(json);

  Map<String, dynamic> toJson() => _$HomeViewToJson(this);

  bool hasRecommendMovies() {
    return recommendMovies?.isNotEmpty ?? false;
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ArtistView {
  final Artist artist;
  final String? image;
  final String? background;
  final List<Release> releases;
  final List<Track> popular;
  final List<Track> singles;
  final List<Artist> similar;

  ArtistView(
      {required this.artist,
      this.image,
      this.background,
      this.releases = const [],
      this.popular = const [],
      this.singles = const [],
      this.similar = const []});

  factory ArtistView.fromJson(Map<String, dynamic> json) =>
      _$ArtistViewFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class WantListView {
  final Artist artist;
  final List<Release> releases;

  WantListView({required this.artist, this.releases = const []});

  factory WantListView.fromJson(Map<String, dynamic> json) =>
      _$WantListViewFromJson(json);

  Map<String, dynamic> toJson() => _$WantListViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ReleaseView {
  final Artist artist;
  final Release release;
  final List<Track> tracks;
  final List<Track> popular;
  final List<Track> singles;
  final List<Release> similar;

  ReleaseView(
      {required this.artist,
      required this.release,
      this.tracks = const [],
      this.popular = const [],
      this.singles = const [],
      this.similar = const []});

  factory ReleaseView.fromJson(Map<String, dynamic> json) =>
      _$ReleaseViewFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseViewToJson(this);

  int get discs {
    int discs = 1;
    for (var t in tracks) {
      if (t.discNum > discs) {
        discs = t.discNum;
      }
    }
    return discs;
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SearchView {
  final List<Artist>? artists;
  final List<Release>? releases;
  final List<Track>? tracks;
  final List<Movie>? movies;
  final List<Series>? series;
  final List<Episode>? episodes;
  final List<Station>? stations;
  final String query;
  final int hits;

  SearchView(
      {this.artists = const [],
      this.releases = const [],
      this.tracks = const [],
      this.movies = const [],
      this.series = const [],
      this.episodes = const [],
      this.stations = const [],
      required this.query,
      required this.hits});

  factory SearchView.empty() => SearchView(query: '', hits: 0);

  factory SearchView.fromJson(Map<String, dynamic> json) =>
      _$SearchViewFromJson(json);

  Map<String, dynamic> toJson() => _$SearchViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ArtistsView {
  final List<Artist> artists;

  ArtistsView({this.artists = const []});

  factory ArtistsView.fromJson(Map<String, dynamic> json) =>
      _$ArtistsViewFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistsViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Artist {
  @JsonKey(name: 'ID')
  final int id;
  final String name;
  final String sortName;
  @JsonKey(name: 'ARID')
  final String? arid;
  final String? disambiguation;
  final String? country;
  final String? area;
  final String? date;
  final String? endDate;
  final String? genre;

  Artist(
      {required this.id,
      required this.name,
      required this.sortName,
      this.arid,
      this.disambiguation,
      this.country,
      this.area,
      this.date,
      this.endDate,
      this.genre});

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Release implements MediaAlbum {
  @JsonKey(name: 'ID')
  final int id;
  final String name;
  final String artist;
  @JsonKey(name: 'RGID')
  final String? rgid;
  @JsonKey(name: 'REID')
  final String? reid;
  final String? disambiguation;
  final String? country;
  final String? asin;
  final String? type;
  final String _date;
  final String? releaseDate;
  final bool artwork;
  final bool frontArtwork;
  final bool backArtwork;
  final String? otherArtwork;
  final bool groupArtwork;
  final int _year;

  Release(
      {required this.id,
      required this.name,
      required this.artist,
      this.rgid,
      this.reid,
      this.disambiguation,
      this.country,
      this.asin,
      this.type,
      String? date,
      this.releaseDate,
      this.artwork = false,
      this.frontArtwork = false,
      this.backArtwork = false,
      this.otherArtwork,
      this.groupArtwork = false})
      : _year = parseYear(date ?? ''),
        _date = date ?? '';

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseToJson(this);

  @override
  String get date => _date;

  @override
  String get album => name;

  @override
  String get creator => artist;

  @override
  String get image => _releaseCoverUrl();

  @override
  int get year => _year;

  int get size => 0;

  String _releaseCoverUrl() {
    final url = groupArtwork ? '/img/mb/rg/$rgid' : '/img/mb/re/$reid';
    if (artwork && frontArtwork) {
      return '$url/front';
    } else if (artwork && isNotNullOrEmpty(otherArtwork)) {
      return url;
    }
    return '';
  }

  String get nameWithDisambiguation {
    return isNotNullOrEmpty(disambiguation) ? '$name ($disambiguation)' : name;
  }

  String get reference => '/music/releases/$id/tracks';
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Track extends DownloadIdentifier implements MediaTrack, OffsetIdentifier {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'UUID')
  final String uuid;
  final String artist;
  final String release;
  @override
  final String date;
  final int trackNum;
  final int discNum;
  @override
  final String title;
  @override
  final int size;
  @JsonKey(name: 'RGID')
  final String? rgid;
  @JsonKey(name: 'REID')
  final String? reid;
  @JsonKey(name: 'RID')
  final String? rid;
  final String releaseTitle;
  final String trackArtist;
  @override
  @JsonKey(name: 'ETag')
  final String etag;
  final bool artwork;
  final bool frontArtwork;
  final bool backArtwork;
  final String? otherArtwork;
  final bool groupArtwork;
  final int _year;

  Track(
      {required this.id,
      required this.uuid,
      required this.artist,
      required this.release,
      this.date = '',
      required this.trackNum,
      required this.discNum,
      required this.title,
      required this.size,
      this.rgid,
      this.reid,
      this.rid,
      required this.releaseTitle,
      this.trackArtist = '',
      required this.etag,
      this.artwork = false,
      this.frontArtwork = false,
      this.backArtwork = false,
      this.otherArtwork,
      this.groupArtwork = false})
      : _year = parseYear(date);

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  Map<String, dynamic> toJson() => _$TrackToJson(this);

  @override
  String get key {
    return ETag(etag).key;
  }

  @override
  String get location {
    return '/api/tracks/$uuid/location';
  }

  @override
  String get album => release;

  @override
  String get creator => preferredArtist();

  @override
  int get disc => discNum;

  @override
  String get image => _trackCoverUrl();

  @override
  int get number => trackNum;

  @override
  int get year => _year;

  int get trackIndex => trackNum - 1;

  String _trackCoverUrl() {
    final url = groupArtwork ? '/img/mb/rg/$rgid' : '/img/mb/re/$reid';
    if (artwork && frontArtwork) {
      return '$url/front';
    } else if (artwork && isNotNullOrEmpty(otherArtwork)) {
      return url;
    }
    return '';
  }

  String preferredArtist() {
    return (trackArtist.isNotEmpty && trackArtist != artist)
        ? trackArtist
        : artist;
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Location {
  @JsonKey(name: 'ID')
  final int id;
  final String url;
  final int size;
  @JsonKey(name: 'ETag')
  final String etag;

  Location(
      {required this.id,
      required this.url,
      required this.size,
      required this.etag});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class RadioView {
  final List<Station>? genre;
  final List<Station>? similar;
  final List<Station>? period;
  final List<Station>? series;
  final List<Station>? other;
  final List<Station>? stream;

  RadioView(
      {this.genre = const [],
      this.similar = const [],
      this.period = const [],
      this.series = const [],
      this.other = const [],
      this.stream = const []});

  factory RadioView.fromJson(Map<String, dynamic> json) =>
      _$RadioViewFromJson(json);

  Map<String, dynamic> toJson() => _$RadioViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Station {
  @JsonKey(name: 'ID')
  final int id;
  final String name;
  final String type;
  final String creator;
  final String image;
  final String description;

  Station(
      {required this.id,
      required this.name,
      required this.type,
      this.creator = '',
      this.image = '',
      this.description = ''});

  factory Station.fromJson(Map<String, dynamic> json) =>
      _$StationFromJson(json);

  Map<String, dynamic> toJson() => _$StationToJson(this);

  String get reference => '/music/radio/stations/$id';
}

abstract class ArtistTracksView {
  Artist get artist;

  List<Track> get tracks;
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SinglesView implements ArtistTracksView {
  @override
  final Artist artist;
  final List<Track> singles;

  SinglesView({required this.artist, this.singles = const []});

  @override
  List<Track> get tracks => singles;

  factory SinglesView.fromJson(Map<String, dynamic> json) =>
      _$SinglesViewFromJson(json);

  Map<String, dynamic> toJson() => _$SinglesViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PopularView implements ArtistTracksView {
  @override
  final Artist artist;
  final List<Track> popular;

  PopularView({required this.artist, this.popular = const []});

  @override
  List<Track> get tracks => popular;

  factory PopularView.fromJson(Map<String, dynamic> json) =>
      _$PopularViewFromJson(json);

  Map<String, dynamic> toJson() => _$PopularViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class MoviesView {
  final List<Movie> movies;

  MoviesView({this.movies = const []});

  factory MoviesView.fromJson(Map<String, dynamic> json) =>
      _$MoviesViewFromJson(json);

  Map<String, dynamic> toJson() => _$MoviesViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class GenreView {
  final String name;
  final List<Movie> movies;

  GenreView({required this.name, this.movies = const []});

  factory GenreView.fromJson(Map<String, dynamic> json) =>
      _$GenreViewFromJson(json);

  Map<String, dynamic> toJson() => _$GenreViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class MovieView {
  final Movie movie;
  final String location;
  final Collection? collection;
  final List<Movie>? other;
  final List<Cast>? cast;
  final List<Crew>? crew;
  final List<Person>? starring;
  final List<Person>? directing;
  final List<Person>? writing;
  final List<String>? genres;
  final int? vote;
  final int? voteCount;

  MovieView(
      {required this.movie,
      required this.location,
      this.collection,
      this.other = const [],
      this.cast = const [],
      this.crew = const [],
      this.starring = const [],
      this.directing = const [],
      this.writing = const [],
      this.genres = const [],
      this.vote,
      this.voteCount});

  // @override
  // String get key {
  //   return ETag(movie.etag).key;
  // }
  //
  // @override
  // String get etag {
  //   return movie.etag;
  // }
  //
  // @override
  // int get size {
  //   return movie.size;
  // }

  factory MovieView.fromJson(Map<String, dynamic> json) =>
      _$MovieViewFromJson(json);

  Map<String, dynamic> toJson() => _$MovieViewToJson(this);

  bool hasGenres() {
    return genres?.isNotEmpty ?? false;
  }

  bool hasRelated() {
    return other?.isNotEmpty ?? false;
  }

  bool hasCast() {
    return cast?.isNotEmpty ?? false;
  }

  bool hasCrew() {
    return crew?.isNotEmpty ?? false;
  }

  bool hasStarring() {
    return starring?.isNotEmpty ?? false;
  }

  bool hasDirecting() {
    return directing?.isNotEmpty ?? false;
  }

  bool hasWriting() {
    return writing?.isNotEmpty ?? false;
  }

  List<Cast> castMembers() {
    return cast ?? [];
  }

  List<Crew> crewMembers() {
    return crew ?? [];
  }

  List<Movie> relatedMovies() {
    return other ?? [];
  }

  List<Person> starringPeople() {
    return starring ?? [];
  }

  List<Person> directingPeople() {
    return directing ?? [];
  }

  List<Person> writingPeople() {
    return writing ?? [];
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Person {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'PEID')
  final int peid;
  final String name;
  final String? profilePath;
  final String? bio;
  final String? birthplace;
  final String? birthday;
  final String? deathday;

  Person(
      {required this.id,
      required this.peid,
      required this.name,
      this.profilePath,
      this.bio,
      this.birthplace,
      this.birthday,
      this.deathday});

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);

  String get image => _profileImageUrl();

  String _profileImageUrl({String size = 'w185'}) {
    return '/img/tm/$size$profilePath';
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Cast {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'TMID')
  final int tmid;
  @JsonKey(name: 'PEID')
  final int peid;
  final String character;
  final Person person;

  Cast(
      {required this.id,
      required this.tmid,
      required this.peid,
      required this.character,
      required this.person});

  factory Cast.fromJson(Map<String, dynamic> json) => _$CastFromJson(json);

  Map<String, dynamic> toJson() => _$CastToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Crew {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'TMID')
  final int tmid;
  @JsonKey(name: 'PEID')
  final int peid;
  final String department;
  final String job;
  final Person person;

  Crew(
      {required this.id,
      required this.tmid,
      required this.peid,
      required this.department,
      required this.job,
      required this.person});

  factory Crew.fromJson(Map<String, dynamic> json) => _$CrewFromJson(json);

  Map<String, dynamic> toJson() => _$CrewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Collection {
  @JsonKey(name: 'ID')
  final int id;
  final String name;
  final String sortName;
  @JsonKey(name: 'TMID')
  final int tmid;

  Collection(
      {required this.id,
      required this.name,
      required this.sortName,
      required this.tmid});

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ProfileView {
  final Person person;
  final List<Movie>? starring;
  final List<Movie>? directing;
  final List<Movie>? writing;

  ProfileView(
      {required this.person,
      this.starring = const [],
      this.directing = const [],
      this.writing = const []});

  factory ProfileView.fromJson(Map<String, dynamic> json) =>
      _$ProfileViewFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileViewToJson(this);

  bool hasStarring() {
    return starring?.isNotEmpty ?? false;
  }

  bool hasDirecting() {
    return directing?.isNotEmpty ?? false;
  }

  bool hasWriting() {
    return writing?.isNotEmpty ?? false;
  }

  List<Movie> starringMovies() {
    return starring ?? [];
  }

  List<Movie> directingMovies() {
    return directing ?? [];
  }

  List<Movie> writingMovies() {
    return writing ?? [];
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Recommend {
  final String name;
  final List<Movie>? movies;

  Recommend({required this.name, this.movies = const []});

  factory Recommend.fromJson(Map<String, dynamic> json) =>
      _$RecommendFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Movie extends DownloadIdentifier
    implements MediaTrack, MediaAlbum, OffsetIdentifier {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'TMID')
  final int tmid;
  @JsonKey(name: 'IMID')
  final String imid;
  @override
  final String title;
  final String sortTitle;
  @override
  final String date;
  final String rating;
  final String tagline;
  final String overview;
  final int budget;
  final int revenue;
  final int runtime;
  final double? voteAverage;
  final int? voteCount;
  final String backdropPath;
  final String posterPath;
  @override
  @JsonKey(name: 'ETag')
  final String etag;
  @override
  final int size;
  final int _year;

  Movie(
      {required this.id,
      required this.tmid,
      required this.imid,
      required this.title,
      required this.sortTitle,
      required this.date,
      required this.rating,
      required this.tagline,
      required this.overview,
      required this.budget,
      required this.revenue,
      required this.runtime,
      this.voteAverage,
      this.voteCount,
      required this.backdropPath,
      required this.posterPath,
      required this.etag,
      required this.size})
      : _year = parseYear(date);

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  Map<String, dynamic> toJson() => _$MovieToJson(this);

  @override
  String get key {
    return ETag(etag).key;
  }

  @override
  String get location {
    throw UnimplementedError;
  }

  @override
  int get year => _year;

  @override
  String get image => _moviePosterUrl();

  @override
  String get creator => '';

  @override
  String get album => title;

  @override
  int get disc => 1;

  @override
  int get number => 0;

  String _moviePosterUrl({String size = 'w342'}) {
    return '/img/tm/$size$posterPath';
  }

  String get titleYear => '$title ($year)';
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Series extends MediaAlbum {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'SID')
  final String sid;
  final String title;
  final String author;
  final String description;
  @override
  final String date;
  final String link;
  @override
  final String image;
  final String copyright;
  @JsonKey(name: 'TTL')
  final int ttl;
  final int _year;

  Series(
      {required this.id,
      required this.sid,
      required this.title,
      required this.author,
      required this.description,
      required this.date,
      required this.link,
      required this.image,
      required this.copyright,
      required this.ttl})
      : _year = parseYear(date);

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesToJson(this);

  @override
  int get year => _year;

  @override
  String get creator => author;

  @override
  String get album => title;

  int get disc => 1;

  int get number => 0;

  String get reference => '/podcasts/series/$id';
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Episode extends DownloadIdentifier
    implements MediaTrack, OffsetIdentifier {
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'SID')
  final String sid;
  @JsonKey(name: 'EID')
  final String eid;
  @override
  final String title;
  final String author;
  final String description;
  @override
  final String date;
  final String link;
  @JsonKey(name: 'URL')
  final String url; // needed?
  @override
  final int size;
  final int _year;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String album;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String image; // set from series

  Episode(
      {required this.id,
      required this.sid,
      required this.eid,
      required this.title,
      required this.author,
      required this.description,
      required this.date,
      required this.link,
      required this.url,
      required this.size,
      this.album = '',
      this.image = ''})
      : _year = parseYear(date);

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);

  Episode copyWith({String? album, String? image}) => Episode(
      album: album ?? this.album,
      image: image ?? this.image,
      id: id,
      sid: sid,
      eid: eid,
      title: title,
      author: author,
      description: description,
      date: date,
      link: link,
      url: url,
      size: size);

  @override
  String get key {
    return eid;
  }

  @override
  String get etag {
    return eid;
  }

  @override
  String get location {
    return '/api/episodes/$id/location';
  }

  @override
  int get year => _year;

  @override
  String get creator => author;

  // @override
  // String get album => title;

  @override
  int get disc => 1;

  @override
  int get number => 0;

  String get reference => '/podcasts/episodes/$id';
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PodcastsView {
  final List<Series> series;

  PodcastsView({this.series = const []});

  factory PodcastsView.fromJson(Map<String, dynamic> json) =>
      _$PodcastsViewFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastsViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SeriesView {
  final Series series;
  final List<Episode> episodes;

  SeriesView({required this.series, this.episodes = const []});

  factory SeriesView.fromJson(Map<String, dynamic> json) =>
      _$SeriesViewFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class EpisodeView {
  final Episode episode;

  EpisodeView({required this.episode});

  factory EpisodeView.fromJson(Map<String, dynamic> json) =>
      _$EpisodeViewFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Offset implements OffsetIdentifier {
  @JsonKey(name: 'ID')
  final int? id;
  @override
  @JsonKey(name: 'ETag')
  final String etag;
  final int duration;
  final int offset;
  final String date;

  Offset(
      {this.id,
      required this.etag,
      required this.duration,
      required this.offset,
      required this.date});

  Offset copyWith({int? offset, int? duration, String? date}) => Offset(
      id: id,
      etag: etag,
      duration: duration ?? this.duration,
      offset: offset ?? this.offset,
      date: date ?? this.date);

  DateTime get dateTime => DateTime.parse(date);

  bool newerThan(Offset o) {
    return dateTime.isAfter(o.dateTime);
  }

  bool hasDuration() {
    return duration > 0;
  }

  Duration position() {
    return Duration(seconds: offset);
  }

  factory Offset.now(
      {required String etag, required Duration offset, Duration? duration}) {
    final date = _offsetDate();
    return Offset(
        etag: etag,
        offset: offset.inSeconds,
        duration: duration?.inSeconds ?? 0,
        date: date);
  }

  static String _offsetDate() {
    // server expects 2006-01-02T15:04:05Z07:00
    return DateTime.now().toUtc().toIso8601String();
  }

  factory Offset.fromJson(Map<String, dynamic> json) => _$OffsetFromJson(json);

  Map<String, dynamic> toJson() => _$OffsetToJson(this);

  @override
  bool operator ==(other) {
    if (other is Offset) {
      // not using date intentionally
      return etag == other.etag &&
          offset == other.offset &&
          duration == other.duration;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(etag, offset, duration);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Offsets {
  final List<Offset> offsets;

  Offsets({required this.offsets});

  factory Offsets.fromOffset(Offset offset) => Offsets(offsets: [offset]);

  factory Offsets.fromJson(Map<String, dynamic> json) =>
      _$OffsetsFromJson(json);

  Map<String, dynamic> toJson() => _$OffsetsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ProgressView {
  final List<Offset> offsets;

  ProgressView({required this.offsets});

  factory ProgressView.fromJson(Map<String, dynamic> json) =>
      _$ProgressViewFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ActivityMovie {
  final String date;
  final Movie movie;

  ActivityMovie({required this.date, required this.movie});

  factory ActivityMovie.fromJson(Map<String, dynamic> json) =>
      _$ActivityMovieFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityMovieToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ActivityTrack {
  final String date;
  final Track track;

  ActivityTrack({required this.date, required this.track});

  factory ActivityTrack.fromJson(Map<String, dynamic> json) =>
      _$ActivityTrackFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityTrackToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ActivityRelease {
  final String date;
  final Release release;

  ActivityRelease({required this.date, required this.release});

  factory ActivityRelease.fromJson(Map<String, dynamic> json) =>
      _$ActivityReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityReleaseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ActivityView {
  final List<ActivityMovie> recentMovies;
  final List<ActivityTrack> recentTracks;
  final List<ActivityRelease> recentReleases;

  ActivityView({
    this.recentMovies = const [],
    this.recentTracks = const [],
    this.recentReleases = const [],
  });

  factory ActivityView.fromJson(Map<String, dynamic> json) =>
      _$ActivityViewFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityViewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class MovieEvent {
  final String date;
  @JsonKey(name: 'TMID')
  final String tmid;
  @JsonKey(name: 'IMID')
  final String imid;
  @JsonKey(name: 'ETag')
  final String etag;

  MovieEvent(
      {required this.date, this.tmid = '', this.imid = '', this.etag = ''});

  factory MovieEvent.now(String etag) {
    final date = Events._eventDate();
    return MovieEvent(etag: etag, date: date);
  }

  factory MovieEvent.fromJson(Map<String, dynamic> json) =>
      _$MovieEventFromJson(json);

  Map<String, dynamic> toJson() => _$MovieEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ReleaseEvent {
  final String date;
  @JsonKey(name: 'RGID')
  final String rgid;
  @JsonKey(name: 'REID')
  final String reid;

  ReleaseEvent({required this.date, this.rgid = '', this.reid = ''});

  factory ReleaseEvent.now(Release release) {
    final date = Events._eventDate();
    return ReleaseEvent(
        date: date, rgid: release.rgid ?? '', reid: release.reid ?? '');
  }

  factory ReleaseEvent.fromJson(Map<String, dynamic> json) =>
      _$ReleaseEventFromJson(json);

  Map<String, dynamic> toJson() => _$ReleaseEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class TrackEvent {
  final String date;
  @JsonKey(name: 'RGID')
  final String rgid;
  @JsonKey(name: 'RID')
  final String rid;
  @JsonKey(name: 'ETag')
  final String etag;

  TrackEvent(
      {required this.date, this.rgid = '', this.rid = '', this.etag = ''});

  factory TrackEvent.now(String etag) {
    final date = Events._eventDate();
    return TrackEvent(etag: etag, date: date);
  }

  factory TrackEvent.fromJson(Map<String, dynamic> json) =>
      _$TrackEventFromJson(json);

  Map<String, dynamic> toJson() => _$TrackEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class Events {
  final List<MovieEvent> movieEvents;
  final List<ReleaseEvent> releaseEvents;
  final List<TrackEvent> trackEvents;

  Events({
    this.movieEvents = const [],
    this.releaseEvents = const [],
    this.trackEvents = const [],
  });

  factory Events.fromJson(Map<String, dynamic> json) => _$EventsFromJson(json);

  Map<String, dynamic> toJson() => _$EventsToJson(this);

  static String _eventDate() {
    // server expects 2006-01-02T15:04:05Z07:00
    return DateTime.now().toUtc().toIso8601String();
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PlaylistView {
  @JsonKey(name: 'ID')
  final int id;
  final String name;
  final int trackCount;

  PlaylistView({required this.id, required this.name, required this.trackCount});

  factory PlaylistView.fromJson(Map<String, dynamic> json) =>
      _$PlaylistViewFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistViewToJson(this);

  String get location => '/api/playlists/$id';
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PlaylistsView {
  final List<PlaylistView> playlists;

  PlaylistsView({this.playlists = const []});

  factory PlaylistsView.fromJson(Map<String, dynamic> json) =>
      _$PlaylistsViewFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistsViewToJson(this);

  String get location => '/api/playlists';
}