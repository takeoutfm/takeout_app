import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @takeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'TakeoutFM'**
  String get takeoutTitle;

  /// No description provided for @artistsLabel.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artistsLabel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Really delete?'**
  String get confirmDelete;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all?'**
  String get deleteAll;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteItem;

  /// No description provided for @deleteDownloadedTracks.
  ///
  /// In en, this message translates to:
  /// **'This will delete all downloaded tracks.'**
  String get deleteDownloadedTracks;

  /// No description provided for @deleteHistory.
  ///
  /// In en, this message translates to:
  /// **'This will delete all saved history.'**
  String get deleteHistory;

  /// No description provided for @deleteEpisode.
  ///
  /// In en, this message translates to:
  /// **'This will delete the downloaded episode.'**
  String get deleteEpisode;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'This will delete the playlist.'**
  String get deletePlaylist;

  /// No description provided for @downloadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsLabel;

  /// No description provided for @downloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadLabel;

  /// No description provided for @hostLabel.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get hostLabel;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get passcodeLabel;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @loginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLabel;

  /// No description provided for @linkLabel.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkLabel;

  /// No description provided for @linkTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Code'**
  String get linkTitle;

  /// No description provided for @linkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Link Complete'**
  String get linkSuccess;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get navArtists;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navRadio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get navRadio;

  /// No description provided for @navPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get navPlayer;

  /// No description provided for @navMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get navMovies;

  /// No description provided for @navGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get navGenres;

  /// No description provided for @similarArtists.
  ///
  /// In en, this message translates to:
  /// **'Similar Artists'**
  String get similarArtists;

  /// No description provided for @playLabel.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playLabel;

  /// No description provided for @refreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshLabel;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @singlesLabel.
  ///
  /// In en, this message translates to:
  /// **'Singles'**
  String get singlesLabel;

  /// No description provided for @popularLabel.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularLabel;

  /// No description provided for @shuffleLabel.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffleLabel;

  /// No description provided for @radioLabel.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radioLabel;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @completeLabel.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeLabel;

  /// No description provided for @genresLabel.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genresLabel;

  /// No description provided for @otherLabel.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherLabel;

  /// No description provided for @decadesLabel.
  ///
  /// In en, this message translates to:
  /// **'Decades'**
  String get decadesLabel;

  /// No description provided for @streamsLabel.
  ///
  /// In en, this message translates to:
  /// **'Streams'**
  String get streamsLabel;

  /// No description provided for @similarReleasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Similar Releases'**
  String get similarReleasesLabel;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @releasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Releases'**
  String get releasesLabel;

  /// No description provided for @tracksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracksLabel;

  /// No description provided for @relatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get relatedLabel;

  /// No description provided for @castLabel.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get castLabel;

  /// No description provided for @crewLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crewLabel;

  /// No description provided for @starringLabel.
  ///
  /// In en, this message translates to:
  /// **'Starring'**
  String get starringLabel;

  /// No description provided for @directingLabel.
  ///
  /// In en, this message translates to:
  /// **'Directing'**
  String get directingLabel;

  /// No description provided for @writingLabel.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get writingLabel;

  /// No description provided for @musicSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Goto Music'**
  String get musicSwitchLabel;

  /// No description provided for @videoSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Goto Movies'**
  String get videoSwitchLabel;

  /// No description provided for @podcastsSwitchLabel.
  ///
  /// In en, this message translates to:
  /// **'Goto Podcasts'**
  String get podcastsSwitchLabel;

  /// No description provided for @moviesLabel.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get moviesLabel;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @searchHelperText.
  ///
  /// In en, this message translates to:
  /// **'text or artist:name or guitar:person'**
  String get searchHelperText;

  /// No description provided for @homeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Settings'**
  String get homeSettingsTitle;

  /// No description provided for @networkSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Network Settings'**
  String get networkSettingsTitle;

  /// No description provided for @settingStreamingTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get settingStreamingTitle;

  /// No description provided for @settingStreamingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow streaming on mobile networks'**
  String get settingStreamingSubtitle;

  /// No description provided for @settingDownloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get settingDownloadsTitle;

  /// No description provided for @settingDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow downloads on mobile networks'**
  String get settingDownloadsSubtitle;

  /// No description provided for @settingArtworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get settingArtworkTitle;

  /// No description provided for @settingArtworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow artwork on mobile networks'**
  String get settingArtworkSubtitle;

  /// No description provided for @settingAutoCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback Caching'**
  String get settingAutoCacheTitle;

  /// No description provided for @settingAutoCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto download while playing'**
  String get settingAutoCacheSubtitle;

  /// No description provided for @settingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingEnabled;

  /// No description provided for @settingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingDisabled;

  /// No description provided for @settingListenBrainzToken.
  ///
  /// In en, this message translates to:
  /// **'ListenBrainz Token'**
  String get settingListenBrainzToken;

  /// No description provided for @settingTrackActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Activity'**
  String get settingTrackActivityTitle;

  /// No description provided for @settingTrackActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit listens to TakeoutFM'**
  String get settingTrackActivitySubtitle;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recent Tracks'**
  String get recentlyPlayed;

  /// No description provided for @recentlyWatched.
  ///
  /// In en, this message translates to:
  /// **'Recently Watched'**
  String get recentlyWatched;

  /// No description provided for @popularTracks.
  ///
  /// In en, this message translates to:
  /// **'Popular Tracks'**
  String get popularTracks;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @seriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get seriesLabel;

  /// No description provided for @episodesLabel.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodesLabel;

  /// No description provided for @variousArtists.
  ///
  /// In en, this message translates to:
  /// **'Various Artists'**
  String get variousArtists;

  /// No description provided for @wantList.
  ///
  /// In en, this message translates to:
  /// **'Want List'**
  String get wantList;

  /// No description provided for @syncPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Sync Playlist'**
  String get syncPlaylist;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get playlistName;

  /// No description provided for @playlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get playlistAdd;

  /// No description provided for @playlistCreate.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get playlistCreate;

  /// No description provided for @trackPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Tracks Like This'**
  String get trackPlaylist;

  /// No description provided for @radioEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Radio Stations'**
  String get radioEmpty;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @recentLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentLabel;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLabel;

  /// No description provided for @streamHistory.
  ///
  /// In en, this message translates to:
  /// **'Stream History'**
  String get streamHistory;

  /// No description provided for @tvEpisodesLabel.
  ///
  /// In en, this message translates to:
  /// **'TV Episodes'**
  String get tvEpisodesLabel;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Really delete {title}?'**
  String deleteTitle(String title);

  /// No description provided for @deleteFree.
  ///
  /// In en, this message translates to:
  /// **'This will free {size} of storage.'**
  String deleteFree(int size);

  /// No description provided for @downloadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloading {name}'**
  String downloadingLabel(String name);

  /// No description provided for @downloadFinishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Finished {name}'**
  String downloadFinishedLabel(String name);

  /// No description provided for @downloadErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Errors {name}'**
  String downloadErrorLabel(String name);

  /// No description provided for @discLabel.
  ///
  /// In en, this message translates to:
  /// **'Disc {num} of {total}'**
  String discLabel(int num, int total);

  /// No description provided for @matchCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matches} =1{1 match} other{{count} matches}}'**
  String matchCount(num count);

  /// No description provided for @podcastProgress.
  ///
  /// In en, this message translates to:
  /// **'{min, plural, =0{Complete} =1{1 min left} other{{min} min left}}'**
  String podcastProgress(num min);

  /// No description provided for @movieProgress.
  ///
  /// In en, this message translates to:
  /// **'{min, plural, =0{Watched} =1{1 min left} other{{min} min left}}'**
  String movieProgress(num min);

  /// No description provided for @trackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{empty} =1{1 track} other{{count} tracks}}'**
  String trackCount(num count);

  /// No description provided for @episodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Episode {num}'**
  String episodeLabel(int num);

  /// No description provided for @seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season {num}'**
  String seasonLabel(int num);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
