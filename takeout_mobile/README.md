# Takeout App

## Android

### Building

```sh
$ flutter pub get
$ flutter pub run build_runner build --delete-conflicting-outputs
$ flutter build apk --release --target-platform android-arm64
# or
$ flutter build apk --release
```

### Installation

```sh
$ adb connect 192.168.xx.yy:zz
$ adb install ./build/app/outputs/flutter-apk/app-release.apk
```
