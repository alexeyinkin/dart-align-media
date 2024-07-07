// ignore_for_file: prefer_const_constructors

import 'package:align_media/align_media.dart';
import 'package:test/test.dart';

const _result = AlignResult(
  media: [
    AlignMediaResult(
      duration: Duration(seconds: 5),
      offset: Duration(seconds: 1),
    ),
    AlignMediaResult(
      duration: Duration(seconds: 7),
      offset: Duration(seconds: 4),
    ),
  ],
  overlappingsOfAny: [
    MediaOverlapping(
      start: Duration(seconds: 4),
      end: Duration(seconds: 6),
      indices: [0, 1],
    ),
  ],
);

void main() {
  group('AlignResult', () {
    test('startOfMediaInOverlapping', () {
      expect(_result.startOfMediaInOverlapping(0, 0), Duration(seconds: 3));
      expect(_result.endOfMediaInOverlapping(0, 0), Duration(seconds: 5));
      expect(_result.startOfMediaInOverlapping(1, 0), Duration.zero);
      expect(_result.endOfMediaInOverlapping(1, 0), Duration(seconds: 2));
    });
  });
}
