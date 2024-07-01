# Build

This source repository contains an Android and Wear OS app, both of which share
a common library.

* takeout\_lib - common code
* takeout\_mobile - the Android app
* takeout\_watch - the Wear OS app

This document describes general steps to build release versions of both apps
using command line tools.

## Requirements

Flutter 3 is required and Android 33+ SDK (Android 13+) is recommended.

* Flutter can be downloaded from [flutter.dev](https://flutter.dev). Follow the
  installation steps and requirements. Steps below assume manual install from a
  linux tar archive.

* Android cmdline-tools zip can be downloaded from
  [developer.android.com](https://developer.android.com/studio).

* Use cmdline-tools to download the Android build-tools and platforms.

These steps may be helpful: (replace xyz with latest versions)

    $ cd ~
    $ tar -Jxvf flutter_linux_xyz-stable.tar.xz
    $ cd flutter

    # Add ~/flutter/bin to your PATH

    $ mkdir ~/android
    $ cd ~/android
    $ unzip commandlinetools-linux-xyz_latest.zip
    $ cd cmdline-tools
    $ mkdir latest
    $ mv * latest
    $ cd ../..
    $ ./cmdline-tools/latest/bin/sdkmanager --list
    $ ./cmdline-tools/latest/bin/sdkmanager --install 'build-tools;34.0.0'
    $ ./cmdline-tools/latest/bin/sdkmanager --install 'platforms;android-34'

    # Add ANDROID_SDK_ROOT=~/android to your environment
    # Optional, add ~/android/platform-tools to your PATH

After these steps you'll have Flutter and the necessary Android tools ready to
build Takeout apps.

## Steps

There is a Makefile that can be used to do the entire build. The steps are:

* Run code generation in the lib directory
* Build the mobile app for Android
* Build the watch app for Wear OS

## Release Builds

Run ``make release`` or ``make bundle``. Both options will build a signed
release apk and ``bundle`` creates and appbundle for Google Play.

A signing key is *required* for release builds. Create a key.properties file in
each of the app ``android`` directories. Do not add keys to source control!
Example:

* takeout\_watch/android/key.properties
* takeout\_mobile/android/key.properties

The key.properties should have the following:

    storePassword=<your store password>
    keyPassword=<your key password>
    keyAlias=<your key alias>
    storeFile=<path to keystore file>

Example:

    storePassword=changeme
    keyPassword=changeme
    keyAlias=mykey
    storeFile=/home/myuser/.keystore

The signing key for both apps can be the same or different.

## Release Assets

Run ``make assets`` to copy built apk files (and bundles) to the assets
directory with appropriate version in the apk filename. For example:

* com.takeoutfm.mobile-0.14.4.apk
* com.takeoutfm.watch-0.14.4.apk
