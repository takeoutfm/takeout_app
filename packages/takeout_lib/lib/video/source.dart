import 'package:takeout_lib/client/resolver.dart';
import 'package:takeout_lib/model.dart';
import 'package:takeout_lib/settings/repository.dart';
import 'package:takeout_lib/tokens/repository.dart';
import 'package:takeout_lib/video/track.dart';

class VideoSource {
  final String url;
  final Map<String, String> headers;

  VideoSource(this.url, this.headers);
}

class PlayerState {
  final VideoTrack video;
  final MediaTrackResolver mediaTrackResolver;
  final TokenRepository tokenRepository;
  final SettingsRepository settingsRepository;
  final Duration? startOffset;

  PlayerState({
    required this.video,
    required this.mediaTrackResolver,
    required this.tokenRepository,
    required this.settingsRepository,
    this.startOffset,
  });

  Future<VideoSource> resolve() async {
    final uri = await mediaTrackResolver.resolve(video);
    String url = uri.toString();
    if (url.startsWith('/api/')) {
      url = '${settingsRepository.settings?.endpoint}$url';
    }
    final headers = tokenRepository.addMediaToken();
    return VideoSource(url, headers);
  }
}
