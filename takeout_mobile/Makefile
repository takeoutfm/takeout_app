# Copyright 2023 defsub
#
# This file is part of TakeoutFM.
#
# TakeoutFM is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# TakeoutFM is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
# more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TakeoutFM.  If not, see <https://www.gnu.org/licenses/>.

FLUTTER = flutter

ADB = adb

APKSIGNER = apksigner

GIT_VERSION ?= $(shell git log --format="%h" -n 1)

SOURCES = $(wildcard lib/*.dart lib/*/*.dart ../takeout_lib/lib/*/*.dart ../takeout_lib/lib/*.dart)

RESOURCES = $(wildcard lib/l10n/*.arb)

TARGET_PLATFORM = android-arm64,android-arm

RELEASE_APK = ./build/app/outputs/flutter-apk/app-release.apk

DEBUG_APK = ./build/app/outputs/flutter-apk/app-debug.apk

.PHONY: build apk

all: apk

pubspec.lock: ../takeout_lib/pubspec.yaml pubspec.yaml
	${FLUTTER} pub get

release: clean update apk

apk: ${RELEASE_APK}

install: apk
	${ADB} install ${RELEASE_APK}

install-debug: debug
	${ADB} install ${DEBUG_APK}

update:
	${FLUTTER} pub get

analyze:
	${FLUTTER} analyze

generate:
	${FLUTTER} pub run build_runner build --delete-conflicting-outputs

${RELEASE_APK}: pubspec.lock ${SOURCES} ${RESOURCES}
	${FLUTTER} build apk --release --target-platform ${TARGET_PLATFORM}

debug: ${DEBUG_APK}

${DEBUG_APK}: pubspec.lock ${SOURCES} ${RESOURCES}
	${FLUTTER} build apk --debug --target-platform ${TARGET_PLATFORM}

bundle: release
	${FLUTTER} build appbundle

verify:
	${APKSIGNER} verify --verbose --print-certs ${RELEASE_APK}

clean:
	${FLUTTER} clean
