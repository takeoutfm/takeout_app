## 0.24.4

- Use playback event stream for duration and index changes
- Include repeat mode in broadcast state

## 0.24.3

- Flutter upgrade to 3.32.0
- Optimized main navbar and navigators (mobile)
- Updated nav and media icons (mobile)
- just\_audio 0.10.3 looks stable now
- Changed skipToPrevious on first track to restart instead of doing nothing
- Fixed duplicate events on index changes
- Put back regular player slider; squiggle was causing excessive repaints
- Refactored some async future usage

## 0.24.2

- Flutter upgrade to 3.29.3
- Update /api/playlist with index & position on track change
- Revert back to just\_audio 0.9.46 - not sure yet why 0.10.0 streams aren't working well
- Player sync playlist will also since track index when playlist unchanged

## 0.24.1

- Flutter upgrade to 3.29.2
- Use Android compileSdkVersion 35
- Update just\_audio deprecated APIs
- Set player maxSkipsOnError to 1

## 0.24.0

- Use Icy cover images if available
- Keep history if Icy stream tracks
- Show stream track history when playing Icy streams
- Added stream history in menu of history/recent screen
- Include TV Episodes in search results
- Put streams first in radio lists
- Add recent artists to Android Auto artists
- Queue and retry ListenBrainz and Activity posts
- Move player repeat button from last to first; only show for music
- Fixed launcher icons
- Use storage\_place\_fork
- Fix watch radio playback

## 0.23.5

- Update foreground service
- Update just\_audio
- Fix icy streams to not route through cache

## 0.23.4

- Fix notification and manifest/AudioService config

## 0.23.3

- Add season divider

## 0.23.2

- Updates for tvList vs tvSeries

## 0.23.1

- Watch support for TV shows

## 0.23.0

- Flutter upgrade to 3.27.3
- Flutter pub upgrade
- Support TV shows

## 0.22.1

- Flutter upgrade to 3.27.0
- Target Android SDK 34

## 0.21.0

- Flutter upgrade to 3.24.4
- Added stats cubit & repo to maintain state
- New activity view in main menu

## 0.20.1

- Fixed repeat icons
- Changed duration update handling
- Flutter pub upgrade
- Added squiggle slider
- Upgrade to Gradle 8.10.2
- Upgrade to Android Studio Ladybug 2024.2.1 Patch 1
- Fixes needed in android/build.gradle for `wear_plus`, `storage_space` and `receive_intent`:
```
    compileSdkVersion 31
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }
```

## 0.20.0

- Fixed empty radio labels
- New popular & recent tracks screens

## 0.19.2

- Fixed bug with empty extras from Android Audio search
- Fixed exception when server has no radio stations + allow refresh
- Flutter upgrade to 3.24.3

## 0.19.1

- Fixed duplicate entries in downloads (spiff cache) - use hash of tracks etags in _cacheKey
- Remove downloaded spiffs + tracks when relative device usage percentage is exceeded
  - new setting cacheUsageThreshold (0-100) specifies the % of total usage allowed
  - example: with 10GB total usage and cacheUsageThreshold=80%, only 8GB will be used by Takeout
- `storage_space` has build issues - fix manually by changing their compileSdkVersion to 31
- Fixed bug with NowPlaying incorrectly retaining started & listened state with new playlists

## 0.19.0

- Added repeat mode (none, all, one) support
- Repeat button is available in app, notification, and Android Auto

## 0.18.4

- Flutter upgrade to 3.24.0 & pub upgrade
- async context and other analyze fixes
- Use `wear_plus` instead of wear
- Remove unused ambient mode support
- `receive_intent` has build issues - fix manually by changing their compileSdkVersion to 31

## 0.18.3

- Android Auto:
  - radio streams use grid, episodes use list
  - use groups and download status
- Support track playlists
  - use in Android Auto search
  - double tap in release tracks
- Flutter upgrade to 3.22.3

## 0.18.2

- Use more grid style in Android Auto
- Include images for radio streams in Android Auto

## 0.18.1

- Use autoCache and autoPlay settings in media browser (for Android Auto)
- Use grid and completion in Android Auto
- Added playlists in Android Auto
- Added movies in Android Auto but no idea now to play video yet
- Enable search in Android Auto

## 0.18.0

- Added support for automatic caching of tracks during playback
- Added setting autoCache to control automatic caching
- Renamed autoplay to autoPlay
- Track history now 500 instead of 100
- Dependency updates

## 0.17.1

- Flutter pub upgrade & tighten
- Fixed playlist play icon
- Added HasPlaylists to index
- Added playlists in watch
- Fixed all *flutter analyze* issue

## 0.17.0

- Update to Flutter 3.22.2, Dart 3.4.3
- Added user playlist support
- Added spiff shuffle support
- Fixed empty history exception
- Pop on link code success

## 0.16.0

- Support 2FA login with passcode (TOTP)
- Support /api/link and LinkWidget UI

## 0.15.4

- Use compileSdkVersion 34 for plugins
- Save & restore position to/from history
- Fix watch re-login on auth expiration
- Update to Android Studio Iguana
- Update to Flutter 3.19.6

## 0.15.3

- Support intents `PLAY_RADIO` & `PLAY_SEARCH`
- Show station creator, image and description
- Fix settings scrolling
- Start of movie mediabrowser support
- Use PopScope instead of WillPopScope

## 0.15.2

- Ensure track index is updated in latest history entry
- Add listened tracks to local track history
- Restore track listen activity

## 0.15.1

- Upgrades for pub.dev, gradle and kotlin
- Note that watch build needs some manual fixes due to outdated wear plugin

## 0.15.0

- Fix home with empty movie recommendations
- Use Wrap for movie genre buttons
- Support Android intents to manage playlist & playback

## 0.14.8

- Change key for media browser (Android Audio) downloads
- Removed optional fields from media player
- Fix empty initial history on watch
- pub upgrade

## 0.14.7

- Fixed watch gradle wrapper sha256
- Redesigned home grid in support of multiple media type views
- In mobile app, multi-tap media bar to cycle through different views
- In watch settings, cycle through music, movie and podcast sort types
- Support podcast subscriptions

## 0.14.5

- Added gradle wrapper sha256
- Moved metadata up one directory for f-droid to find it

## 0.14.4

- Disable shrink resources

## 0.14.3

- Android versionCode changed to align with version
- audio controls fix

## 0.14.2

- Fixed restore playlist state
- Build updates
