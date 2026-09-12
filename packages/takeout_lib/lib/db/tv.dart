// Copyright 2026 defsub
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
import 'package:takeout_lib/client/repository.dart';

class TVRepository {
  final TVProvider _provider;

  TVRepository({
    required ClientRepository clientRepository,
    TVProvider? provider,
  }) : _provider = provider ?? DefaultTVProvider(clientRepository);

  Iterable<String> findByEpisodeName(String query) {
    return _provider.findByEpisodeName(query);
  }

  TVEpisode? findTVEpisode(
    String name, {
    int? year,
    int? season,
    int? episode,
  }) {
    return _provider.findTVEpisode(
      name,
      year: year,
      season: season,
      episode: episode,
    );
  }

  Future<void> reload() {
    return _provider.reload();
  }
}

abstract class TVProvider {
  Iterable<String> findByEpisodeName(String query);

  TVEpisode? findTVEpisode(String name, {int? year, int? season, int? episode});

  Future<void> reload();
}

class DefaultTVProvider extends TVProvider {
  final ClientRepository clientRepository;
  final episodes = <String, TVEpisode>{};
  final series = <int, TVSeries>{};
  final names = <String>[];

  DefaultTVProvider(this.clientRepository) {
    _load();
  }

  @override
  Future<void> reload() {
    return _load(ttl: Duration.zero);
  }

  Future<void> _load({Duration? ttl}) async {
    return clientRepository
        .tvList(ttl: ttl)
        .then((view) {
          series.clear();
          episodes.clear();
          names.clear();
          for (var s in view.series) {
            series[s.tvid] = s;
          }
          for (var e in view.episodes) {
            episodes[e.etag] = e; // only unique id
            names.add(e.name);
          }
        })
        .onError((error, stackTrace) {
          Future.delayed(const Duration(minutes: 3), () => _load());
        });
  }

  @override
  Iterable<String> findByEpisodeName(String query) {
    final result = <String>[];
    query = query.toLowerCase();
    result.addAll(names.where((name) => name.toLowerCase().contains(query)));
    return result;
  }

  @override
  TVEpisode? findTVEpisode(
    String name, {
    int? year,
    int? season,
    int? episode,
  }) {
    name = name.toLowerCase();
    final se = (season != null && episode != null)
        ? 'S${season}E$episode'
        : null;
    for (var e in episodes.values) {
      // TODO slow search but should be ok
      if (e.name.toLowerCase() == name &&
          (year == null || year == e.year) &&
          (se == null || se == e.se)) {
        return e;
      }
    }
    return null;
  }
}
