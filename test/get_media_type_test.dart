import 'package:align_media/align_media.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('getMediaType', () {
    test('exception if none', () async {
      expect(
        () async => AlignMedia.getMediaType('lib/align_media.dart'),
        throwsException,
      );
    });

    test('audio', () async {
      expect(await AlignMedia.getMediaType(audioPath), MediaType.audio);
    });

    test('audio', () async {
      expect(await AlignMedia.getMediaType(video1Path), MediaType.video);
    });
  });
}
