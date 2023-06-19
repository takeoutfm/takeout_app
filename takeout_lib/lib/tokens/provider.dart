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

import 'model.dart';
import 'tokens.dart';

abstract class TokenProvider {
  void add({String? accessToken, String? refreshToken, String? mediaToken});

  String? get accessToken;

  String? get refreshToken;

  String? get mediaToken;
}

class DefaultTokenProvider implements TokenProvider {
  final TokensCubit _tokens;

  DefaultTokenProvider(TokensCubit tokens) : _tokens = tokens;

  Tokens get tokens => _tokens.state.tokens;

  @override
  String? get accessToken => _tokens.state.tokens.access;

  @override
  String? get refreshToken => _tokens.state.tokens.refresh;

  @override
  String? get mediaToken => _tokens.state.tokens.media;

  @override
  void add({String? accessToken, String? refreshToken, String? mediaToken}) {
    _tokens.add(_tokens.state.tokens.copyWith(
        access: accessToken, refresh: refreshToken, media: mediaToken));
  }
}
