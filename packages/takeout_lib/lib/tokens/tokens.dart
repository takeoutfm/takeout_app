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

part 'tokens.g.dart';

@JsonSerializable()
class TokensState {
  final Tokens tokens;

  TokensState(this.tokens);

  factory TokensState.fromJson(Map<String, dynamic> json) =>
      _$TokensStateFromJson(json);

  Map<String, dynamic> toJson() => _$TokensStateToJson(this);
}

class TokensCubit extends HydratedCubit<TokensState> {
  TokensCubit() : super(TokensState(Tokens.initial()));

  void add(Tokens tokens) {
    emit(TokensState(tokens));
  }

  void removeAll() {
    emit(TokensState(Tokens.initial()));
  }

  @override
  TokensState fromJson(Map<String, dynamic> json) =>
      TokensState.fromJson(json['tokens'] as Map<String, dynamic>);

  @override
  Map<String, dynamic>? toJson(TokensState state) => {'tokens': state.toJson()};
}
