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

import 'package:takeout_lib/cache/file_provider.dart';
import 'package:takeout_lib/cache/file_repository.dart';
import 'package:takeout_lib/client/etag.dart';

abstract class TrackIdentifier extends FileIdentifier {}

class ETagIdentifier implements FileIdentifier {
  final ETag etag;

  ETagIdentifier(this.etag);

  @override
  String get key => etag.key;
}

class TrackCacheRepository extends FileCacheRepository {
  TrackCacheRepository({required super.directory});

  Future<void> removeByETag(ETag etag) {
    return remove(ETagIdentifier(etag));
  }
}
