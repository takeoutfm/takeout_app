import 'package:flutter/material.dart';

const titleEdgeInset = 20.0;

class SliverTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;

  const SliverTitle(
    this.title, {
    super.key,
    this.style,
    this.padding = const EdgeInsetsGeometry.all(titleEdgeInset),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Text(title, style: style),
      ),
    );
  }
}
