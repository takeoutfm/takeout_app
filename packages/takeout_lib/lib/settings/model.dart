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

import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Settings {
  final String user;
  final String host;
  final bool allowMobileStreaming;
  final bool allowMobileDownload;
  final bool allowMobileArtistArtwork;
  final bool autoPlay;
  final bool autoCache;
  final String? listenBrainzToken;
  final bool enableListenBrainz;
  final bool enableTrackActivity;
  final int cacheUsageThreshold;

  Settings({
    required this.user,
    required this.host,
    required this.allowMobileStreaming,
    required this.allowMobileDownload,
    required this.allowMobileArtistArtwork,
    this.autoPlay = true,
    this.autoCache = false,
    this.listenBrainzToken,
    this.enableListenBrainz = true,
    this.enableTrackActivity = true,
    this.cacheUsageThreshold = 80,
  });

  factory Settings.initial() => Settings(
    user: 'takeout',
    host: 'https://example.com',
    allowMobileArtistArtwork: true,
    allowMobileDownload: true,
    allowMobileStreaming: true,
  );

  String get endpoint {
    if (host.startsWith(RegExp(r'(http|https)://.+/'))) {
      return host;
    } else if (host.contains(RegExp(r'^[a-zA-Z0-9\\.-]+$'))) {
      return 'https://$host';
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
    bool? autoPlay,
    bool? autoCache,
    String? listenBrainzToken,
    bool? enableListenBrainz,
    bool? enableTrackActivity,
    int? cacheUsageThreshold,
  }) => Settings(
    user: user ?? this.user,
    host: host ?? this.host,
    allowMobileStreaming: allowMobileStreaming ?? this.allowMobileStreaming,
    allowMobileDownload: allowMobileDownload ?? this.allowMobileDownload,
    allowMobileArtistArtwork:
        allowMobileArtistArtwork ?? this.allowMobileArtistArtwork,
    autoPlay: autoPlay ?? this.autoPlay,
    autoCache: autoCache ?? this.autoCache,
    listenBrainzToken: listenBrainzToken ?? this.listenBrainzToken,
    enableListenBrainz: enableListenBrainz ?? this.enableListenBrainz,
    enableTrackActivity: enableTrackActivity ?? this.enableTrackActivity,
    cacheUsageThreshold: cacheUsageThreshold ?? this.cacheUsageThreshold,
  );

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
