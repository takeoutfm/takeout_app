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

import 'dart:math';

import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool playing;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
    this.playing = false,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;

  void _onChanged(double value) {
    if (!_dragging) {
      _dragging = true;
    }
    setState(() {
      _dragValue = value;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(Duration(milliseconds: value.round()));
    }
  }

  void _onChangeEnd(double value) {
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(Duration(milliseconds: value.round()));
    }
    _dragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        // SquigglySlider(
        //   useLineThumb: true,
        //   squiggleAmplitude: widget.playing ? 5.0 : 0,
        //   squiggleWavelength: widget.playing ? 10.0 : 0,
        //   squiggleSpeed: 0.05,
        //   min: 0.0,
        //   max: widget.duration.inMilliseconds.toDouble(),
        //   value: value,
        //   onChanged: _onChanged,
        //   onChangeEnd: _onChangeEnd,
        // ),
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: _onChanged,
          onChangeEnd: _onChangeEnd,
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch('$_remaining')
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
