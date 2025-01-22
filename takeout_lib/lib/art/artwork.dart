// Copyright 2023 defsub
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

const coverAspectRatio = 1.0;
const coverGridWidth = 250.0;
const coverGridHeight = 250.0;

const posterAspectRatio = 0.6667;
const posterGridWidth = 166.75;
const posterGridHeight = 250.0;

const seriesAspectRatio = 1.0;
const seriesGridWidth = 250.0;
const seriesGridHeight = 250.0;

const listTileIconHeight = 56.0;

class Artwork {
  final String _url;
  final double? width, height, aspectRatio;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Icon? placeholder;
  final Color? color;
  final BlendMode? blendMode;

  String get url => _url;

  Artwork(
    this._url,
    this.width,
    this.height,
    this.fit, {
    this.aspectRatio = 1.0,
    this.borderRadius,
    this.placeholder,
    this.color,
    this.blendMode,
  });

  factory Artwork.artist(String url) =>
      Artwork(url, 1000, 1000, BoxFit.fitHeight,
          placeholder: const Icon(Icons.people));

  factory Artwork.cover(String url) =>
      Artwork(url, coverGridWidth, coverGridHeight, BoxFit.fitHeight,
          placeholder: const Icon(Icons.album));

  factory Artwork.playerCover(String url) =>
      Artwork(url, coverGridWidth, coverGridHeight, BoxFit.fitHeight,
          placeholder: const Icon(Icons.album));

  factory Artwork.circleCover(String url,
          {required double radius,
          double? width,
          double? height,
          Color? color,
          BlendMode? blendMode}) =>
      Artwork(url, width, height, BoxFit.cover,
          color: color,
          blendMode: blendMode,
          borderRadius: BorderRadius.circular(radius),
          placeholder: const Icon(Icons.album, size: listTileIconHeight));

  factory Artwork.tileCover(String url) => Artwork(url, null, null, null,
      borderRadius: BorderRadius.circular(4),
      placeholder: const Icon(Icons.album, size: listTileIconHeight));

  factory Artwork.tilePodcast(String url) => Artwork(url, null, null, null,
      borderRadius: BorderRadius.circular(4),
      placeholder: const Icon(Icons.podcasts, size: listTileIconHeight));

  factory Artwork.tilePoster(String url) => Artwork(url, null, null, null,
      borderRadius: BorderRadius.circular(4),
      placeholder: const Icon(Icons.movie, size: listTileIconHeight));

  factory Artwork.tileStill(String url) => Artwork(url, null, null, null,
      borderRadius: BorderRadius.circular(4),
      placeholder: const Icon(Icons.tv, size: listTileIconHeight));

  factory Artwork.background(String url) =>
      Artwork(url, 1920, 1080, BoxFit.cover);

  factory Artwork.coverGrid(String url) =>
      Artwork(url, coverGridWidth, coverGridHeight, BoxFit.fill,
          aspectRatio: coverAspectRatio,
          placeholder: const Icon(Icons.album, size: coverGridHeight / 3));

  factory Artwork.posterGrid(String url) =>
      Artwork(url, posterGridWidth, posterGridHeight, BoxFit.fill,
          aspectRatio: posterAspectRatio, placeholder: const Icon(Icons.movie));

  factory Artwork.seriesGrid(String url) =>
      Artwork(url, seriesGridWidth, seriesGridHeight, BoxFit.fill,
          aspectRatio: seriesAspectRatio,
          placeholder: const Icon(Icons.podcasts));

  String get tag => url;
}
