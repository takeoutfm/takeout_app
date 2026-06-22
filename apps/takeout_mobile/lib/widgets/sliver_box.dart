import 'package:flutter/material.dart';

class SliverBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  static const edgePadding = 20.0;

  const SliverBox({
    super.key,
    required this.child,
    this.decoration,
    this.padding = const EdgeInsetsGeometry.all(edgePadding),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(padding: padding, decoration: decoration, child: child),
    );
  }
}
