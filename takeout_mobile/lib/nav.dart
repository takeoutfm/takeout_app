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

import 'package:flutter/material.dart';
import 'package:takeout_mobile/spiff/widget.dart';

final globalAppKey = GlobalKey<NavigatorState>();

void globalPush({required WidgetBuilder builder}) {
  globalAppKey.currentState?.push(MaterialPageRoute<void>(builder: builder));
}

void push(BuildContext context, {required WidgetBuilder builder}) {
  Navigator.push(context, MaterialPageRoute<void>(builder: builder));
}

void pushSpiff(BuildContext context, FetchSpiff fetch, {String? ref}) {
  push(context, builder: (_) => SpiffWidget(fetch: fetch, ref: ref));
}

void pushPlaylist(BuildContext context, FetchSpiff fetch, {String? ref}) {
  push(context,
      builder: (_) => SpiffWidget(
            fetch: fetch,
            ref: ref,
          ));
}
