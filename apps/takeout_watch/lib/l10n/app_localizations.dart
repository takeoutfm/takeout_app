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

  /// No description provided for @musicLabel.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicLabel;

  /// No description provided for @podcastsLabel.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get podcastsLabel;

  /// No description provided for @radioLabel.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radioLabel;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @recentLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentLabel;

  /// No description provided for @playlistsLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlistsLabel;

  /// No description provided for @downloadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsLabel;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @connectLabel.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectLabel;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next >'**
  String get nextLabel;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get confirmLogout;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutLabel;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Really delete?'**
  String get confirmDelete;

  /// No description provided for @downloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadLabel;

  /// No description provided for @confirmDownload.
  ///
  /// In en, this message translates to:
  /// **'Download?'**
  String get confirmDownload;

  /// No description provided for @artistsLabel.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artistsLabel;

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

  /// No description provided for @loginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLabel;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

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

  /// No description provided for @settingAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get settingAutoPlay;

  /// No description provided for @settingAutoCache.
  ///
  /// In en, this message translates to:
  /// **'Play/Cache'**
  String get settingAutoCache;

  /// No description provided for @settingMobileDownloads.
  ///
  /// In en, this message translates to:
  /// **'Mobile Downloads'**
  String get settingMobileDownloads;

  /// No description provided for @settingMobileStreaming.
  ///
  /// In en, this message translates to:
  /// **'Mobile Streaming'**
  String get settingMobileStreaming;

  /// No description provided for @settingsMediaSort.
  ///
  /// In en, this message translates to:
  /// **'Media Sort'**
  String get settingsMediaSort;

  /// No description provided for @settingListenBrainz.
  ///
  /// In en, this message translates to:
  /// **'ListenBrainz'**
  String get settingListenBrainz;

  /// No description provided for @settingTrackActivity.
  ///
  /// In en, this message translates to:
  /// **'Track Activity'**
  String get settingTrackActivity;

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

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Code invalid'**
  String get codeInvalid;

  /// No description provided for @codeNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get codeNotLinked;

  /// No description provided for @connectivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivityLabel;

  /// No description provided for @deviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceLabel;

  /// No description provided for @displayLabel.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displayLabel;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundLabel;

  /// No description provided for @bluetoothLabel.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetoothLabel;

  /// No description provided for @resumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeLabel;

  /// No description provided for @moviesLabel.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get moviesLabel;

  /// No description provided for @starringLabel.
  ///
  /// In en, this message translates to:
  /// **'Starring'**
  String get starringLabel;

  /// No description provided for @writingLabel.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get writingLabel;

  /// No description provided for @directingLabel.
  ///
  /// In en, this message translates to:
  /// **'Directing'**
  String get directingLabel;

  /// No description provided for @musicSortType.
  ///
  /// In en, this message translates to:
  /// **'Music Sort'**
  String get musicSortType;

  /// No description provided for @filmSortType.
  ///
  /// In en, this message translates to:
  /// **'Movie Sort'**
  String get filmSortType;

  /// No description provided for @podcastSortType.
  ///
  /// In en, this message translates to:
  /// **'Podcast Sort'**
  String get podcastSortType;

  /// No description provided for @showsLabel.
  ///
  /// In en, this message translates to:
  /// **'TV Shows'**
  String get showsLabel;
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
