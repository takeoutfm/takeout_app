// Copyright 2024 defsub
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

import 'stats.dart';

class StatsRepository {
  StatsCubit? cubit;

  void init(StatsCubit cubit) {
    this.cubit = cubit;
  }

  StatsState get state {
    return cubit?.state ?? StatsState.initial();
  }

  StatsType get type {
    return state.type;
  }

  IntervalType get interval {
    return state.interval;
  }
}
