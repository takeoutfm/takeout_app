import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:takeout_mobile/app/context.dart';

class SliverGridTile extends StatelessWidget {
  final Widget image;
  final String title;
  final String? subtitle;
  final String? badge;
  final GestureTapCallback? onTap;
  final int titleMaxLines;
  final double height;

  const SliverGridTile({
    required this.image,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleMaxLines = 1,
    this.height = 50,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      onSelect: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GridTile(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
              if (badge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: context.labelSmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: height,
                  color: Colors.black.withValues(alpha: 0.65),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        title,
                        style: context.gridTitle,
                        maxLines: titleMaxLines,
                        softWrap: titleMaxLines > 1 ? true : null,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: context.gridSubtitle,
                          maxLines: 1,
                          // softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}
