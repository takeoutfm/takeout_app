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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/art/scaffold.dart';

import '../art/builder.dart';
import '../model.dart';
import '../spiff/model.dart';
import 'player.dart';

typedef PlayerScaffoldBodyFunc = Widget? Function(Color?, {Spiff? spiff});

class PlayerScaffold extends StatelessWidget {
  final PlayerScaffoldBodyFunc? body;
  final Widget? drawer;
  final Widget? bottomSheet;

  const PlayerScaffold({super.key, this.body, this.drawer, this.bottomSheet});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Player, PlayerEvent>(
      buildWhen: (context, state) {
        return state is PlayerLoad || state is PlayerIndexChange;
      },
      builder: (context, state) {
        Spiff? spiff;
        String? image;
        if (state is PlayerLoad || state is PlayerIndexChange) {
          spiff = state.spiff;
          if (state.spiff.isNotEmpty) {
            image = state.spiff[state.spiff.index].image;
          }
        }
        return FutureBuilder<Color?>(
          future: image != null ? getImageBackgroundColor(context, image) : null,
          builder: (context, snapshot) {
            return Scaffold(
              bottomSheet: bottomSheet,
              drawer: drawer,
              backgroundColor: snapshot.data,
              body: body?.call(snapshot.data, spiff: spiff),
            );
          },
        );
      },
    );
  }
}
