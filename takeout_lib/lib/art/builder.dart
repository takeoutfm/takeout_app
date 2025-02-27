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
import 'package:logger/logger.dart';
import 'package:octo_image/octo_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:takeout_lib/context/context.dart';
import 'package:takeout_lib/util.dart';

import 'artwork.dart';

class ArtworkBuilder {
  static final log = Logger();

  final Artwork? primary;
  final Artwork? secondary;
  final Icon placeholder;
  final Icon errorIcon;
  final urlStream = BehaviorSubject<String?>();
  final bool hero;
  Artwork? _artwork;
  ImageProvider? _provider;

  static final artworkErrors = ExpiringSet<String>(const Duration(hours: 1));

  static Artwork? _pick(Artwork? primary, Artwork? secondary) {
    if (primary != null) {
      return artworkErrors.contains(primary.url) ? secondary : primary;
    }
    return secondary;
  }

  ArtworkBuilder(this.primary,
      {this.secondary,
      this.placeholder = const Icon(Icons.image_outlined, size: 40),
      this.errorIcon = const Icon(Icons.broken_image_outlined, size: 40),
      this.hero = false})
      : _artwork = _pick(primary, secondary);

  factory ArtworkBuilder.artist(String? artistUrl, String? coverUrl) =>
      ArtworkBuilder(artistUrl != null ? Artwork.artist(artistUrl) : null,
          secondary: coverUrl != null ? Artwork.cover(coverUrl) : null);

  Widget _cachedImage(BuildContext context, Artwork artwork) {
    if (artworkErrors.contains(artwork.url)) {
      // TODO not needed due to pick?
      return errorIcon;
    }
    urlStream.add(artwork.url);
    final imageProvider = context.imageProvider.get(artwork.url);
    //CachedNetworkImage.logLevel = CacheManagerLogLevel.verbose;
    final image = OctoImage(
        image: imageProvider,
        width: artwork.width,
        height: artwork.height,
        color: artwork.color,
        colorBlendMode: artwork.blendMode,
        fit: artwork.fit,
        placeholderBuilder: (_) => artwork.placeholder ?? placeholder,
        errorBuilder: (context, error, stack) {
          log.w('OctoImage error', error: error);
          artworkErrors.add(imageProvider.url);
          if (imageProvider.url == primary?.url && secondary != null) {
            // primary failed, forget it and use secondary
            _artwork = secondary!;
            return _cachedImage(context, secondary!);
          }
          urlStream.add(null);
          return errorIcon;
        });
    _provider = imageProvider;
    final borderRadius = artwork.borderRadius;
    return borderRadius != null
        ? ClipRRect(
            borderRadius: borderRadius,
            child: _hero(image, artwork.tag))
        : _hero(image, artwork.tag);
  }

  Widget _hero(Widget image, String tag) {
    return hero ? Hero(tag: tag, child: image) : image;
  }

  String? get url => _artwork?.url;

  Widget build(BuildContext context) {
    final a = _artwork;
    if (a == null) {
      return placeholder;
    }
    return isNullOrEmpty(a.url)
        ? a.placeholder ?? placeholder
        : _cachedImage(context, a);
  }

  Future<Color?> getBackgroundColor(BuildContext context) async {
    final imageProvider = _provider;
    if (imageProvider == null) {
      return null;
    }
    return _backgroundColor(context, imageProvider);
  }
}

final _colorCache = <String, Color>{};

Future<Color> getImageBackgroundColor(BuildContext context, String url) async {
  var color = _colorCache[url];
  if (color != null) {
    return color;
  }
  final provider = context.imageProvider.get(url);
  color = await _backgroundColor(context, provider);
  _colorCache[url] = color;
  return color;
}

Future<Color> _backgroundColor(
    BuildContext context, ImageProvider imageProvider) async {
  final paletteGenerator =
      await PaletteGenerator.fromImageProvider(imageProvider);
  if (!context.mounted) {
    return Future.value(Colors.black);
  }
  final brightness = MediaQuery.of(context).platformBrightness;
  if (brightness == Brightness.dark) {
    return paletteGenerator.darkVibrantColor?.color ??
        paletteGenerator.darkMutedColor?.color ??
        Theme.of(context).colorScheme.surface;
  } else {
    return paletteGenerator.lightVibrantColor?.color ??
        paletteGenerator.lightMutedColor?.color ??
        Theme.of(context).colorScheme.surface;
  }
}
