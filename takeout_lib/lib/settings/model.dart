// Copyright 2023 defsub
//
// This file is part of Takeout.
//
// Takeout is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Takeout is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for
// more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Takeout.  If not, see <https://www.gnu.org/licenses/>.

import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum HomeGridType { mix, downloads, released, added }

@JsonSerializable()
class Settings {
  final String user;
  final String host;
  final bool allowMobileStreaming;
  final bool allowMobileDownload;
  final bool allowMobileArtistArtwork;
  final bool autoplay;
  final HomeGridType homeGridType;

  Settings({
    required this.user,
    required this.host,
    required this.allowMobileStreaming,
    required this.allowMobileDownload,
    required this.allowMobileArtistArtwork,
    this.autoplay = true,
    this.homeGridType = HomeGridType.mix,
  });

  factory Settings.initial() => Settings(
        user: 'takeout',
        host: 'https://example.com',
        allowMobileArtistArtwork: true,
        allowMobileDownload: true,
        allowMobileStreaming: true,
        autoplay: true,
        homeGridType: HomeGridType.mix,
      );

  String get endpoint {
    if (host.startsWith(RegExp(r'(http|https)://.+/'))) {
      return host;
    } else if (host.contains(RegExp(r'^[a-zA-Z0-9\.-]+$'))) {
      return 'https://$host/';
    } else {
      return host;
    }
  }

  Settings copyWith({
    String? user,
    String? host,
    bool? allowMobileStreaming,
    bool? allowMobileDownload,
    bool? allowMobileArtistArtwork,
    bool? autoplay,
    HomeGridType? homeGridType,
  }) =>
      Settings(
        user: user ?? this.user,
        host: host ?? this.host,
        allowMobileStreaming: allowMobileStreaming ?? this.allowMobileStreaming,
        allowMobileDownload: allowMobileDownload ?? this.allowMobileDownload,
        allowMobileArtistArtwork:
            allowMobileArtistArtwork ?? this.allowMobileArtistArtwork,
        autoplay: autoplay ?? this.autoplay,
        homeGridType: homeGridType ?? this.homeGridType,
      );

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
