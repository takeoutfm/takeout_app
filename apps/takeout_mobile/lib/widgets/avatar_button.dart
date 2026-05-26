import 'package:flutter/material.dart';
import 'package:takeout_lib/art/cover.dart';

class AvatarButton extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onPressed;

  const AvatarButton({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
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
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
