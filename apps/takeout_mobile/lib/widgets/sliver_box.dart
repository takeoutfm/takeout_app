import 'package:flutter/material.dart';

class SliverBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  static const edgePadding = 20.0;

  const SliverBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsGeometry.all(edgePadding),
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(padding: padding, child: child),
    );
  }
}
