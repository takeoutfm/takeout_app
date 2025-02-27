# Android Auto

TakeoutFM for Android supports Android Auto with music, podcasts, and Internet
radio streaming.

Android Auto only allows apps from Google Play to be enabled by default so
developer builds or sideloads will not work without additional setup. These
additional steps are included below.

## Enable Android Auto developer mode

* Go to Android Auto in settings
* Tap *Version* in the About section
* Tap *Version and permission info* 10 times
* Tap OK when Allow development settings appears

See this page for more details:

https://developer.android.com/training/cars/testing

## Add TakeoutFM to the Launcher

* Go to Android Auto in settings
* Tap *Customize Launcher* in the Display section
* Click the checkbox to include TakeoutFM
* Adjust the sort order as desired

That's it. Android Auto and TakeoutFM should work now.

## Desktop Head Unit

Follow these steps to test Android Auto on a desktop - no car required. Basic
steps are:

* Install DHU
* Run the DHU
* Setup ADB

See this page for more details:

https://developer.android.com/training/cars/testing/dhu

### Steps used for a Linux system

* Enable wireless debugging in Android settings
* Tap *Start head unit server* in the Android Auto menu
* Execute these Linux commands:

	$ adb forward tcp:5277 tcp:5277
	5277
	$ ./Android/Sdk/extras/google/auto/desktop-head-unit
	Android Auto - Desktop Head Unit
    Build: 2022-03-30-438482292
    Version: 2.0-linux
    ...
	Verify returned: ok

* Tap *Stop head unit server* in the Android Auto menu
