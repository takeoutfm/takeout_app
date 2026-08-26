// Copyright 2026 defsub
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takeout_lib/api/model.dart';
import 'package:takeout_lib/art/artwork.dart';
import 'package:takeout_lib/art/cover.dart';
import 'package:takeout_lib/index/index.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/film/movie_details.dart';
import 'package:takeout_mobile/widgets/media_progress.dart';
import 'package:takeout_mobile/widgets/sliver_grid_tile.dart';


import 'package:flutter/material.dart';

class Genre {
  final String name;
  final IconData? icon;
  final String? imageUrl;

  const Genre({required this.name, this.icon, this.imageUrl});

  static const _genres = {
    'Action': Genre(name: 'Action', icon: Icons.surfing),
    'Adventure': Genre(name: 'Adventure', icon: Icons.hiking),
    'Animation': Genre(name: 'Animation', icon: Icons.brush),
    'Comedy': Genre(name: 'Comedy', icon: Icons.mood),
    'Crime': Genre(name: 'Crime', icon: Icons.local_atm),
    'Documentary': Genre(name: 'Documentary', icon: Icons.book),
    'Drama': Genre(name: 'Drama', icon: Icons.theater_comedy),
    'Family': Genre(name: 'Family', icon: Icons.child_friendly_rounded),
    'Fantasy': Genre(name: 'Fantasy', icon: Icons.local_attraction),
    'History': Genre(name: 'History', icon: Icons.history_edu),
    'Horror': Genre(name: 'Horror', icon: Icons.dark_mode),
    'Music': Genre(name: 'Music', icon: Icons.music_note),
    'Mystery': Genre(name: 'Mystery', icon: Icons.question_mark),
    'Romance': Genre(name: 'Romance', icon: Icons.favorite),
    'Science Fiction': Genre(name: 'Science Fiction', icon: Icons.rocket_launch),
    'TV Movie': Genre(name: 'TV Movie', icon: Icons.tv),
    'Thriller': Genre(name: 'Thriller', icon: Icons.bolt),
    'War': Genre(name: 'War', icon: Icons.flag),
    'Western': Genre(name: 'Western', icon: Icons.star),
  };

  static Genre of(String name) {
    return _genres[name] ?? Genre(name: name, icon: Icons.movie);
  }
}

class GenreCard extends StatelessWidget {
  final Genre genre;
  final VoidCallback? onTap;

  const GenreCard({super.key, required this.genre, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image, if provided
            if (genre.imageUrl != null)
              Image.network(
                genre.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
              ),

            // Dark scrim so text stays legible over an image
            if (genre.imageUrl != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),

            // Content: icon + name
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (genre.icon != null)
                    Icon(genre.icon, color: Colors.white, size: 28),
                  if (genre.icon != null) const SizedBox(height: 8),
                  Text(
                    genre.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
