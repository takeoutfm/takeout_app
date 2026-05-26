import 'package:flutter/material.dart';
import 'package:takeout_mobile/app/app.dart';
import 'package:takeout_mobile/app/context.dart';
import 'package:takeout_mobile/downloads.dart';
import 'package:takeout_mobile/nav.dart';
import 'package:takeout_mobile/pages/activity.dart';
import 'package:takeout_mobile/pages/link.dart';
import 'package:takeout_mobile/pages/playlists.dart';
import 'package:takeout_mobile/settings/widget.dart';
import 'package:takeout_mobile/widgets/menu.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return popupMenu(context, [
      PopupItem.playlist(context, (context) => _onRecentTracks(context)),
      PopupItem.activity(context, (context) => _onTrackStats(context)),
      PopupItem.playlists(context, (context) => _onPlaylists(context)),
      PopupItem.divider(),
      PopupItem.settings(context, (context) => _onSettings(context)),
      PopupItem.downloads(context, (context) => _onDownloads(context)),
      PopupItem.linkLogin(context, (_) => _onLink(context)),
      PopupItem.logout(context, (_) => _onLogout(context)),
      PopupItem.divider(),
      PopupItem.about(context, (context) => _onAbout(context)),
    ]);
  }

  void _onDownloads(BuildContext context) {
    push(context, builder: (_) => const DownloadsWidget());
  }

  void _onSettings(BuildContext context) {
    push(context, builder: (_) => const SettingsWidget());
  }

  void _onRecentTracks(BuildContext context) {
    push(context, builder: (_) => TrackHistoryWidget());
  }

  void _onTrackStats(BuildContext context) {
    push(context, builder: (_) => TrackStatsWidget());
  }

  void _onPlaylists(BuildContext context) {
    push(context, builder: (_) => PlaylistsWidget());
  }

  void _onLink(BuildContext context) {
    push(context, builder: (_) => LinkWidget());
  }

  void _onLogout(BuildContext context) {
    context.logout();
  }

  void _onAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: context.strings.takeoutTitle,
      applicationVersion: appVersion,
      applicationLegalese: 'Copyleft \u00a9 2020-2026 defsub',
      applicationIcon: Image.asset(
        'assets/logo_192.png',
        width: 96,
        height: 96,
      ),
      children: <Widget>[
        InkWell(
          child: const Text(
            appHome,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.blueAccent,
            ),
          ),
          onTap: () => launchUrl(Uri.parse(appHome)),
        ),
      ],
    );
  }
}
