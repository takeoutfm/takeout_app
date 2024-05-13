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
import 'package:rotary_scrollbar/rotary_scrollbar.dart';
import 'package:takeout_watch/app/context.dart';

class RotaryList<T> extends StatefulWidget {
  final List<T> entries;
  final String? title;
  final String? subtitle;
  final Widget Function(BuildContext, T) tileBuilder;

  const RotaryList(this.entries,
      {required this.tileBuilder, this.title, this.subtitle, super.key});

  @override
  State<RotaryList<T>> createState() => _RotaryListState<T>();
}

class _RotaryListState<T> extends State<RotaryList<T>> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final subtitle = widget.subtitle;
    Widget? header;
    if (title != null) {
      if (subtitle != null) {
        header = ListTile(
            title: Center(child: Text(title)),
            subtitle: Center(child: Text(subtitle)));
      } else {
        header = Container(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Center(
                child:
                    Text(title, style: context.listTileTheme.titleTextStyle)));
      }
    }
    // add some padding at the bottom
    const footer = SizedBox.square(dimension: 8);
    return RotaryScrollWrapper(
      rotaryScrollbar: RotaryScrollbar(
        controller: scrollController,
      ),
      child: ListView.builder(
          controller: scrollController,
          itemBuilder: (context, index) {
            final entry = widget.entries[index];
            final item = Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  color: Colors.white10,
                  child: widget.tileBuilder.call(context, entry),
                ));
            if (index == 0 && header != null) {
              return Column(
                children: [
                  header,
                  item,
                ],
              );
            } else if (index == widget.entries.length - 1) {
              return Column(
                children: [
                  item,
                  footer,
                ],
              );
            } else {
              return item;
            }
          },
          itemCount: widget.entries.length),
    );
  }
}
