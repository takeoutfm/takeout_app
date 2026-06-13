import 'package:flutter/material.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_mobile/app/context.dart';

class AvatarButton extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const AvatarButton({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            avatar(context, imageUrl),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.labelMedium?.copyWith(color: Colors.white),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.labelSmall?.copyWith(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
