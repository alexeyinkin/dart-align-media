import 'package:align_media/align_media.dart';
import 'package:test/test.dart';

import 'common.dart';


void main() {
  test('align audio video', () async {
    final r = await AlignMedia.align([
      audioPath,
      video1Path,
    ]);

    expect(r.media[0].duration, const Duration(microseconds: 13557551));
    expect(r.media[0].offset, const Duration(microseconds: 3390000));

    expect(r.media[1].duration, const Duration(microseconds: 25007891));
    expect(r.media[1].offset, Duration.zero);

    expect(r.overlappingsOfAny[0].start, const Duration(microseconds: 3390000));
    expect(r.overlappingsOfAny[0].end, const Duration(microseconds: 16947551));
    expect(r.overlappingsOfAny[0].indices, [0, 1]);
  });
}
