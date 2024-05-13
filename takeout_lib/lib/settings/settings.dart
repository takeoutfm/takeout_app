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

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'settings.g.dart';

@JsonSerializable()
class SettingsState {
  final Settings settings;

  SettingsState(this.settings);

  factory SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);
}

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(SettingsState(Settings.initial()));

  void add(
          {String? user,
          String? host,
          bool? allowStreaming,
          bool? allowDownload,
          bool? allowArtistArtwork,
          String? listenBrainzToken,
          bool? enableListenBrainz,
          bool? enableTrackActivity}) =>
      emit(SettingsState(state.settings.copyWith(
        user: user,
        host: host,
        allowMobileStreaming: allowStreaming,
        allowMobileDownload: allowDownload,
        allowMobileArtistArtwork: allowArtistArtwork,
        listenBrainzToken: listenBrainzToken,
        enableListenBrainz: enableListenBrainz,
        enableTrackActivity: enableTrackActivity,
      )));

  void apply(Settings settings) {
    // don't allow user & host to be changed here.
    emit(SettingsState(state.settings.copyWith(
      allowMobileArtistArtwork: settings.allowMobileArtistArtwork,
      allowMobileDownload: settings.allowMobileDownload,
      allowMobileStreaming: settings.allowMobileStreaming,
      autoplay: settings.autoplay,
      listenBrainzToken: settings.listenBrainzToken,
      enableListenBrainz: settings.enableListenBrainz,
      enableTrackActivity: settings.enableTrackActivity,
    )));
  }

  set user(String user) {
    emit(SettingsState(state.settings.copyWith(user: user)));
  }

  set host(String host) {
    emit(SettingsState(state.settings.copyWith(host: host)));
  }

  set allowStreaming(bool value) {
    emit(SettingsState(state.settings.copyWith(allowMobileStreaming: value)));
  }

  set allowDownload(bool value) {
    emit(SettingsState(state.settings.copyWith(allowMobileDownload: value)));
  }

  set allowArtistArtwork(bool value) {
    emit(SettingsState(
        state.settings.copyWith(allowMobileArtistArtwork: value)));
  }

  set autoplay(bool value) {
    emit(SettingsState(state.settings.copyWith(autoplay: value)));
  }

  set listenBrainzToken(String value) {
    emit(SettingsState(state.settings.copyWith(listenBrainzToken: value)));
  }

  set enabledListenBrainz(bool value) {
    emit(SettingsState(state.settings.copyWith(enableListenBrainz: value)));
  }

  set enableTrackActivity(bool value) {
    emit(SettingsState(state.settings.copyWith(enableTrackActivity: value)));
  }

  @override
  SettingsState fromJson(Map<String, dynamic> json) =>
      SettingsState.fromJson(json['settings'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(SettingsState state) =>
      {'settings': state.toJson()};
}
