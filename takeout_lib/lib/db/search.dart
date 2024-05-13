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

import 'package:takeout_lib/client/repository.dart';
import 'package:takeout_lib/db/artist.dart';

class Search {
  final ClientRepository clientRepository;
  final ArtistRepository _artistRepository;

  Search({required this.clientRepository, ArtistRepository? artistRepository})
      : _artistRepository = artistRepository ??
            ArtistRepository(clientRepository: clientRepository);

  Iterable<String> findArtistsByName(String query) {
    return _artistRepository.findByName(query);
  }

  void reload() {
    _artistRepository.reload();
  }
}
