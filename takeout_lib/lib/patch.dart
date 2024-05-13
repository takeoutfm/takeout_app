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

List<Map<String, dynamic>> patchAppend(String ref) {
  return [
    {
      'op': 'add',
      'path': '/playlist/track/-',
      'value': {'\$ref': ref}
    }
  ];
}

List<Map<String, dynamic>> patchReplace(String ref, String type,
    {String? creator, String? title}) {
  return [
    if (creator != null)
      {'op': 'replace', 'path': '/playlist/creator', 'value': creator},
    if (title != null)
      {'op': 'replace', 'path': '/playlist/title', 'value': title},
    {'op': 'replace', 'path': '/type', 'value': type},
    {'op': 'replace', 'path': '/playlist/track', 'value': <String>[]},
    {
      'op': 'add',
      'path': '/playlist/track/-',
      'value': {'\$ref': ref}
    }
  ];
}

List<Map<String, dynamic>> patchRemove(String index) {
  return [
    {'op': 'remove', 'path': '/playlist/track/$index'}
  ];
}

List<Map<String, dynamic>> patchClear() {
  return [
    {'op': 'replace', 'path': '/playlist/track', 'value': <String>[]}
  ];
}

List<Map<String, dynamic>> patchPosition(int index, double position) {
  return [
    {'op': 'replace', 'path': '/index', 'value': index},
    {'op': 'replace', 'path': '/position', 'value': position}
  ];
}
