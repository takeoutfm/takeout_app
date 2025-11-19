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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/settings/repository.dart';

class ArtProvider {
  final SettingsRepository settingsRepository;
  final ClientRepository clientRepository;
  final CacheManager _cacheManager;

  ArtProvider(this.settingsRepository, this.clientRepository)
    : _cacheManager = _CoverCacheManager(clientRepository);

  CachedNetworkImageProvider get(String url) {
    return CachedNetworkImageProvider(
      _resolve(url),
      cacheManager: _cacheManager,
    );
  }

  String _resolve(String url) {
    final endpoint = settingsRepository.settings?.endpoint;
    return url.startsWith('/img/') ? '$endpoint$url' : url;
  }
}

// redo of DefaultCacheManager to use the takeout client
class _CoverCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'libCachedImageData'; // same as DefaultCacheManager

  // static final _CoverCacheManager _instance = _CoverCacheManager._();
  static _CoverCacheManager? _instance;

  factory _CoverCacheManager(final ClientRepository clientRepository) {
    _instance ??= _CoverCacheManager._(clientRepository);
    return _instance!;
  }

  _CoverCacheManager._(ClientRepository clientRepository)
    : super(
        Config(
          key,
          fileService: HttpFileService(httpClient: clientRepository.client),
        ),
      );
}
