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

import 'package:takeout_lib/api/model.dart';

import 'subscribed.dart';

class SubscribedRepository {
  SubscribedCubit? cubit;

  void init(SubscribedCubit cubit) {
    this.cubit = cubit;
  }

  SubscribedState get state {
    return cubit?.state ?? SubscribedState.initial();
  }

  List<Series> get series {
    return state.series;
  }
}
