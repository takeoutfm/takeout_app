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

import 'dart:io';

import 'provider.dart';
import 'tokens.dart';

class TokenRepository {
  TokenProvider? _provider;

  TokenRepository({TokenProvider? provider}) : _provider = provider;

  void init(TokensCubit tokens) {
    _provider = DefaultTokenProvider(tokens);
  }

  void add({String? accessToken, String? refreshToken, String? mediaToken}) {
    _provider?.add(
      accessToken: accessToken,
      refreshToken: refreshToken,
      mediaToken: mediaToken,
    );
  }

  String? get accessToken => _provider?.accessToken;

  String? get refreshToken => _provider?.refreshToken;

  String? get mediaToken => _provider?.mediaToken;

  Map<String, String> addAccessToken({Map<String, String>? headers}) =>
      _addAuthToken(headers, accessToken);

  Map<String, String> addRefreshToken({Map<String, String>? headers}) =>
      _addAuthToken(headers, refreshToken);

  Map<String, String> addMediaToken({Map<String, String>? headers}) =>
      _addAuthToken(headers, mediaToken);

  Map<String, String> _addAuthToken(
    Map<String, String>? headers,
    String? token,
  ) {
    headers = headers ?? <String, String>{};
    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }
}
