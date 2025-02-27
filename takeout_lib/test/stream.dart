import 'dart:io';

import 'package:test/test.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  test('some test', () async {
    final stream =
        Stream<int>.periodic(const Duration(milliseconds: 100), (count) => count + 1);
    await stream
        .throttleTime(const Duration(seconds: 5))
        .timeout(const Duration(seconds: 10), onTimeout: (sink) {
      sink.add(0);
    }).firstWhere((count) {
      print(count);
      return count > 1000;
    });
  });
}
