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
    final hasImage = genre.imageUrl != null;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // White-on-scrim is fine regardless of theme when there's a background
    // image — contrast is against the photo, not the app background. But
    // with no image, content sits directly on the card's own surface tint,
    // so it needs to track the theme or it's invisible in light mode.
    final contentColor = hasImage ? Colors.white : onSurface;

    return DpadFocusable(
      onSelect: onTap,
      child: Material(
        color: onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(
                  genre.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),

              if (hasImage)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.fromRGBO(0, 0, 0, 0.5),
                        // scrim stays black regardless of theme
                      ],
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (genre.icon != null)
                      Icon(genre.icon, color: contentColor, size: 28),
                    if (genre.icon != null) const SizedBox(height: 8),
                    Text(
                      genre.name,
                      style: TextStyle(
                        color: contentColor,
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
