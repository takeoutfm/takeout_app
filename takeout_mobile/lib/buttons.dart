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
import 'package:takeout_lib/connectivity/connectivity.dart';
import 'package:takeout_mobile/app/context.dart';

import 'style.dart';

const playIcon = Icon(Icons.play_arrow, size: 32);
// TODO use material resume icon when available
const resumeIcon = Icon(Icons.playlist_play, size: 32);

class PlayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;

  const PlayButton({super.key, this.onPressed, this.icon = playIcon});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: icon, onPressed: onPressed);
  }
}

abstract class _ConnectivityButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback? onPressed;

  const _ConnectivityButton({required this.icon, this.onPressed, super.key});

  bool _allowed(BuildContext context, ConnectivityState state);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return IconButton(
          icon: icon,
          onPressed: _allowed(context, state) ? onPressed : null,
        );
      },
    );
  }
}

class DownloadButton extends _ConnectivityButton {
  const DownloadButton({
    super.key,
    super.icon = const Icon(iconsDownload),
    super.onPressed,
  });

  @override
  bool _allowed(BuildContext context, ConnectivityState state) {
    final settings = context.settings.state.settings;
    final allow = settings.allowMobileDownload;
    return state.mobile ? allow : true;
  }
}

class StreamingButton extends _ConnectivityButton {
  const StreamingButton({super.key, super.icon = playIcon, super.onPressed});

  @override
  bool _allowed(BuildContext context, ConnectivityState state) {
    final settings = context.settings.state.settings;
    final allow = settings.allowMobileStreaming;
    return state.mobile ? allow : true;
  }
}
