import 'package:flutter/material.dart';

class OptionalText extends StatelessWidget {
  final String? text;
  final TextStyle? style;

  const OptionalText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final t = text;
    if (t == null || t.isEmpty) {
      return SizedBox.shrink();
    }
    return Text(t, style: style);
  }
}
