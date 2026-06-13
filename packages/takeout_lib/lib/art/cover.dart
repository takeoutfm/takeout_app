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

import 'artwork.dart';
import 'builder.dart';

Widget? tileCover(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.tileCover(url)).build(context);
}

Widget? tileCover64(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.tileCover64(url)).build(context);
}

Widget? tilePodcast(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.tilePodcast(url)).build(context);
}

Widget? tilePoster(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.tilePoster(url)).build(context);
}

Widget? tileStill(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.tileStill(url)).build(context);
}

Widget releaseSmallCover(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.cover(url), hero: true).build(context);
}

Widget artistSmallPoster(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.artistSmallPoster(url), hero: true).build(context);
}

Widget moviePoster(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.moviePoster(url), hero: true).build(context);
}

Widget movieSmallPoster(BuildContext context, String url) {
  return ArtworkBuilder(
    Artwork.movieSmallPoster(url),
    hero: true,
  ).build(context);
}

Widget backdropImage(BuildContext context, String url) {
  print('backdrop $url');
  return ArtworkBuilder(Artwork.background(url)).build(context);
}

Widget spiffCover(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.cover(url), hero: true).build(context);
}

Widget gridCover(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.coverGrid(url), hero: true).build(context);
}

Widget gridPoster(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.posterGrid(url), hero: true).build(context);
}

Widget gridSeries(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.seriesGrid(url), hero: true).build(context);
}

Widget playerCover(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.playerCover(url), hero: false).build(context);
}

Widget tvSeriesSmallPoster(BuildContext context, String url) {
  return ArtworkBuilder(
    Artwork.tvSeriesSmallPoster(url),
    hero: true,
  ).build(context);
}

Widget gridTVEpisode(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.tvEpisodeGrid(url), hero: true).build(context);
}

Widget gridPodcastEpisode(BuildContext context, String url) {
  return ArtworkBuilder(
    Artwork.podcastEpisodeGrid(url),
    hero: true,
  ).build(context);
}

Widget avatar(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.avatar(url), hero: false).build(context);
}

Widget fillImage(BuildContext context, String url) {
  return ArtworkBuilder(Artwork.fillImage(url), hero: false).build(context);
}

Widget? circleCover(
  BuildContext context,
  String url, {
  required double radius,
  double? width,
  double? height,
  Color? color,
  BlendMode? blendMode,
}) {
  return ArtworkBuilder(
    Artwork.circleCover(
      url,
      radius: radius,
      height: height,
      color: color,
      blendMode: blendMode,
    ),
  ).build(context);
}
