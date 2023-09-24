# Copyright 2023 defsub
#
# This file is part of Takeout.
#
# Takeout is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
# more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

FLUTTER = flutter

VERSION = $(shell cat .version)

RELEASE_APK = build/app/outputs/flutter-apk/app-release.apk

ASSETS = ./assets

.PHONY: all clean release assets

all:
	${MAKE} --directory=takeout_lib generate
	${MAKE} --directory=takeout_mobile all
	${MAKE} --directory=takeout_watch all

release:
	${MAKE} --directory=takeout_lib generate
	${MAKE} --directory=takeout_mobile release
	${MAKE} --directory=takeout_watch release

clean:
	rm -rf ${ASSETS}
	${MAKE} --directory=takeout_lib clean
	${MAKE} --directory=takeout_mobile clean
	${MAKE} --directory=takeout_watch clean

tag:
	git tag --list | grep -q v${VERSION} || git tag v${VERSION}
	git push origin v${VERSION}

assets:
	mkdir ${ASSETS}
	cp takeout_mobile/${RELEASE_APK} ${ASSETS}/com.takeoutfm.mobile-${VERSION}.apk
	cp takeout_watch/${RELEASE_APK} ${ASSETS}/com.takeoutfm.watch-${VERSION}.apk

version:
	scripts/version.sh && git commit -a

publish: clean version tag release assets
