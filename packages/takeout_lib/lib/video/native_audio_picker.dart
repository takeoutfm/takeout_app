import 'package:flutter/material.dart';
import 'package:better_native_video_player/better_native_video_player.dart';

/// A modal bottom sheet for selecting audio tracks
class AudioPickerModal extends StatefulWidget {
  const AudioPickerModal({
    super.key,
    required this.controller,
    this.onAudioTrackChange,
  });

  final NativeVideoPlayerController controller;
  final void Function(int)? onAudioTrackChange;

  @override
  State<AudioPickerModal> createState() => _AudioPickerModalState();
}

class _AudioPickerModalState extends State<AudioPickerModal> {
  List<NativeVideoPlayerAudioTrack> _audioTracks = [];
  NativeVideoPlayerAudioTrack? _selectedTrack;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAudioTracks();
  }

  Future<void> _loadAudioTracks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tracks = await widget.controller.getAvailableAudioTracks();

      setState(() {
        _audioTracks = tracks;
        _selectedTrack = tracks.isEmpty
            ? null
            : tracks.firstWhere(
                (track) => track.isSelected,
                orElse: () => tracks.first,
              );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio tracks: $e')),
        );
      }
    }
  }

  Future<void> _selectTrack(NativeVideoPlayerAudioTrack track) async {
    try {
      await widget.controller.setAudioTrack(track);
      setState(() {
        _selectedTrack = track;
      });

      widget.onAudioTrackChange?.call(track.index);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${track.displayName}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting audio track: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.audiotrack, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Audio Tracks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(),

          // Loading or audio tracks list
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (_audioTracks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.audiotrack_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alternate audio tracks available',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Unlike subtitles, audio has no "off" option — the
                  // video always needs an active audio track.
                  for (final track in _audioTracks) _buildTrackTile(track),
                ],
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrackTile(NativeVideoPlayerAudioTrack track) {
    final isSelected = _selectedTrack?.index == track.index;

    return ListTile(
      leading: const Icon(Icons.audiotrack),
      title: Text(
        track.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        track.language.toUpperCase(),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle) : null,
      onTap: () => _selectTrack(track),
    );
  }
}

/// Shows the audio track picker modal
Future<void> showAudioTrackPicker({
  required BuildContext context,
  required NativeVideoPlayerController controller,
  final void Function(int)? onAudioTrackChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AudioPickerModal(
      controller: controller,
      onAudioTrackChange: onAudioTrackChanged,
    ),
  );
}
