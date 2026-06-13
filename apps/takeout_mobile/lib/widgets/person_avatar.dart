import 'package:flutter/material.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_mobile/widgets/avatar_button.dart';

class PersonAvatar extends StatelessWidget {
  final Person person;
  final String? subtitle;
  final VoidCallback onTap;

  const PersonAvatar(this.person, {super.key, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AvatarButton(
      name: person.name,
      subtitle: subtitle,
      imageUrl: person.image,
      onTap: onTap,
    );
  }
}
