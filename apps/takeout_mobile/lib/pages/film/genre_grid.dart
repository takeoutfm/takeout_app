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

import 'package:dpad/dpad.dart';
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

  static const Map<String, IconData> _genreIcons = {
    'Action': Icons.sports_martial_arts,
    'Adventure': Icons.explore,
    'Animation': Icons.movie_filter,
    'Comedy': Icons.mood,
    'Crime': Icons.gavel,
    'Documentary': Icons.videocam,
    'Drama': Icons.theater_comedy,
    'Family': Icons.diversity_3,
    'Fantasy': Icons.auto_fix_high,
    'History': Icons.history_edu,
    'Horror': Icons.dark_mode,
    'Music': Icons.music_note,
    'Mystery': Icons.fingerprint,
    'Romance': Icons.favorite,
    'Science Fiction': Icons.rocket_launch,
    'TV Movie': Icons.tv,
    'Thriller': Icons.crisis_alert,
    'War': Icons.military_tech,
    'Western': Icons.landscape,
  };

  static final Map<String, Genre> _genres = _genreIcons.map(
    (name, icon) => MapEntry(name, Genre(name: name, icon: icon)),
  );

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
    return DpadFocusable(
      onSelect: onTap,
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
      ),
    );
  }
}
