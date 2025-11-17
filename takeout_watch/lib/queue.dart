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
import 'package:takeout_lib/empty.dart';
import 'package:takeout_lib/player/player.dart';
import 'package:takeout_watch/app/context.dart';

class PlayerQueue extends StatefulWidget {
  const PlayerQueue({super.key});

  @override
  State<PlayerQueue> createState() => PlayerQueueState();
}

class PlayerQueueState extends State<PlayerQueue> {
  bool showQueue = false;

  @override
  Widget build(BuildContext context) {
    return showQueue
        ? playerQueue(context)
        : IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              setState(() {
                showQueue = true;
              });
            });
  }

  Widget playerQueue(BuildContext context) {
    String? location;
    return BlocBuilder<Player, PlayerEvent>(
        buildWhen: (_, state) =>
            state is PlayerIndexChange ||
            state.spiff.playlist.location != location,
        builder: (context, state) {
          if (state is PlayerIndexChange ||
              state.spiff.playlist.location != location) {
            location = state.spiff.playlist.location;
            return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= notification.minExtent) {
                    setState(() {
                      showQueue = false;
                    });
                    return true;
                  }
                  return false;
                },
                child: DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.1,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return Material(
                          color: Colors.black87,
                          child: ListView.builder(
                              controller: scrollController,
                              itemCount: state.spiff.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  selected: state.currentIndex == index,
                                  onTap: () =>
                                      context.player.skipToIndex(index),
                                  title: Text(
                                    state.spiff[index].title,
                                  ),
                                );
                              }));
                    }));
          } else {
            return const EmptyWidget();
          }
        });
  }
}
