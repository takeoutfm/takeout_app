// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get takeoutTitle => 'TakeoutFM';

  @override
  String get artistsLabel => 'Artists';

  @override
  String get confirmDelete => 'Really delete?';

  @override
  String get deleteAll => 'Delete all?';

  @override
  String get deleteItem => 'Delete?';

  @override
  String get deleteDownloadedTracks =>
      'This will delete all downloaded tracks.';

  @override
  String get deleteHistory => 'This will delete all saved history.';

  @override
  String get deleteEpisode => 'This will delete the downloaded episode.';

  @override
  String get deletePlaylist => 'This will delete the playlist.';

  @override
  String get downloadsLabel => 'Downloads';

  @override
  String get downloadLabel => 'Download';

  @override
  String get hostLabel => 'Host';

  @override
  String get userLabel => 'User';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passcodeLabel => 'Passcode';

  @override
  String get codeLabel => 'Code';

  @override
  String get loginLabel => 'Login';

  @override
  String get linkLabel => 'Link';

  @override
  String get linkTitle => 'Link Code';

  @override
  String get linkSuccess => 'Link Complete';

  @override
  String get navHome => 'Home';

  @override
  String get navArtists => 'Artists';

  @override
  String get navSearch => 'Search';

  @override
  String get navHistory => 'History';

  @override
  String get navRadio => 'Radio';

  @override
  String get navPlayer => 'Player';

  @override
  String get navMovies => 'Movies';

  @override
  String get navGenres => 'Genres';

  @override
  String get similarArtists => 'Similar Artists';

  @override
  String get playLabel => 'Play';

  @override
  String get refreshLabel => 'Refresh';

  @override
  String get logoutLabel => 'Logout';

  @override
  String get aboutLabel => 'About';

  @override
  String get singlesLabel => 'Singles';

  @override
  String get popularLabel => 'Popular';

  @override
  String get shuffleLabel => 'Shuffle';

  @override
  String get radioLabel => 'Radio';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get completeLabel => 'Complete';

  @override
  String get genresLabel => 'Genres';

  @override
  String get otherLabel => 'Other';

  @override
  String get decadesLabel => 'Decades';

  @override
  String get streamsLabel => 'Streams';

  @override
  String get similarReleasesLabel => 'Similar Releases';

  @override
  String get searchLabel => 'Search';

  @override
  String get releasesLabel => 'Releases';

  @override
  String get tracksLabel => 'Tracks';

  @override
  String get relatedLabel => 'Related';

  @override
  String get castLabel => 'Cast';

  @override
  String get crewLabel => 'Crew';

  @override
  String get starringLabel => 'Starring';

  @override
  String get directingLabel => 'Directing';

  @override
  String get writingLabel => 'Writing';

  @override
  String get musicSwitchLabel => 'Goto Music';

  @override
  String get videoSwitchLabel => 'Goto Movies';

  @override
  String get podcastsSwitchLabel => 'Goto Podcasts';

  @override
  String get moviesLabel => 'Movies';

  @override
  String get historyLabel => 'History';

  @override
  String get searchHelperText => 'text or artist:name or guitar:person';

  @override
  String get homeSettingsTitle => 'Home Settings';

  @override
  String get networkSettingsTitle => 'Network Settings';

  @override
  String get settingStreamingTitle => 'Streaming';

  @override
  String get settingStreamingSubtitle => 'Allow streaming on mobile networks';

  @override
  String get settingDownloadsTitle => 'Downloads';

  @override
  String get settingDownloadsSubtitle => 'Allow downloads on mobile networks';

  @override
  String get settingArtworkTitle => 'Artwork';

  @override
  String get settingArtworkSubtitle => 'Allow artwork on mobile networks';

  @override
  String get settingAutoCacheTitle => 'Playback Caching';

  @override
  String get settingAutoCacheSubtitle => 'Auto download while playing';

  @override
  String get settingEnabled => 'Enabled';

  @override
  String get settingDisabled => 'Disabled';

  @override
  String get settingListenBrainzToken => 'ListenBrainz Token';

  @override
  String get settingTrackActivityTitle => 'Track Activity';

  @override
  String get settingTrackActivitySubtitle => 'Submit listens to TakeoutFM';

  @override
  String get recentlyPlayed => 'Recent Tracks';

  @override
  String get recentlyWatched => 'Recently Watched';

  @override
  String get popularTracks => 'Popular Tracks';

  @override
  String get history => 'History';

  @override
  String get seriesLabel => 'Series';

  @override
  String get episodesLabel => 'Episodes';

  @override
  String get variousArtists => 'Various Artists';

  @override
  String get wantList => 'Want List';

  @override
  String get syncPlaylist => 'Sync Playlist';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get playlists => 'Playlists';

  @override
  String get playlistName => 'Name';

  @override
  String get playlistAdd => 'Add to playlist';

  @override
  String get playlistCreate => 'New playlist';

  @override
  String get trackPlaylist => 'Tracks Like This';

  @override
  String get radioEmpty => 'No Radio Stations';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get lastYear => 'Last Year';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get allLabel => 'All';

  @override
  String get recentLabel => 'Recent';

  @override
  String get activityLabel => 'Activity';

  @override
  String get streamHistory => 'Stream History';

  @override
  String get tvEpisodesLabel => 'TV Episodes';

  @override
  String deleteTitle(String title) {
    return 'Really delete $title?';
  }

  @override
  String deleteFree(int size) {
    final intl.NumberFormat sizeNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String sizeString = sizeNumberFormat.format(size);

    return 'This will free $sizeString of storage.';
  }

  @override
  String downloadingLabel(String name) {
    return 'Downloading $name';
  }

  @override
  String downloadFinishedLabel(String name) {
    return 'Finished $name';
  }

  @override
  String downloadErrorLabel(String name) {
    return 'Errors $name';
  }

  @override
  String discLabel(int num, int total) {
    final intl.NumberFormat numNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String numString = numNumberFormat.format(num);
    final intl.NumberFormat totalNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String totalString = totalNumberFormat.format(total);

    return 'Disc $numString of $totalString';
  }

  @override
  String matchCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
      zero: 'No matches',
    );
    return '$_temp0';
  }

  @override
  String podcastProgress(num min) {
    String _temp0 = intl.Intl.pluralLogic(
      min,
      locale: localeName,
      other: '$min min left',
      one: '1 min left',
      zero: 'Complete',
    );
    return '$_temp0';
  }

  @override
  String movieProgress(num min) {
    String _temp0 = intl.Intl.pluralLogic(
      min,
      locale: localeName,
      other: '$min min left',
      one: '1 min left',
      zero: 'Watched',
    );
    return '$_temp0';
  }

  @override
  String trackCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: 'empty',
    );
    return '$_temp0';
  }

  @override
  String episodeLabel(int num) {
    final intl.NumberFormat numNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String numString = numNumberFormat.format(num);

    return 'Episode $numString';
  }

  @override
  String seasonLabel(int num) {
    final intl.NumberFormat numNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String numString = numNumberFormat.format(num);

    return 'Season $numString';
  }
}
