import 'package:align_media/align_media.dart';
import 'package:test/test.dart';

void main() {
  void callWithPermutations2(
    List<Duration> offsets,
    List<Duration> durations,
    void Function(List<Duration> offsets, List<Duration> durations) callback,
  ) {
    callback(offsets, durations);
    callback([...offsets.reversed], [...durations.reversed]);
  }

  test('error if different sizes', () {
    expect(
      () => AlignMedia.getOverlappingsOfAny(
        offsets: const [Duration(seconds: 1)],
        durations: [],
      ),
      throwsArgumentError,
    );
  });

  test('0 none', () {
    expect(AlignMedia.getOverlappingsOfAny(offsets: [], durations: []), []);
  });

  test('1 none', () {
    expect(
      AlignMedia.getOverlappingsOfAny(
        offsets: const [Duration(seconds: 1)],
        durations: const [Duration(seconds: 1)],
      ),
      [],
    );
  });

  test('2 none', () {
    // -==-----
    // -----===
    const offsets = [Duration(seconds: 1), Duration(seconds: 5)];
    const durations = [Duration(seconds: 2), Duration(seconds: 3)];

    callWithPermutations2(offsets, durations, (offsets, durations) {
      expect(
        AlignMedia.getOverlappingsOfAny(
          offsets: offsets,
          durations: durations,
        ),
        [],
      );
    });
  });

  test('2 touching none', () {
    // -====---
    // -----===
    const offsets = [Duration(seconds: 1), Duration(seconds: 5)];
    const durations = [Duration(seconds: 4), Duration(seconds: 3)];

    callWithPermutations2(offsets, durations, (offsets, durations) {
      expect(
        AlignMedia.getOverlappingsOfAny(
          offsets: offsets,
          durations: durations,
        ),
        [],
      );
    });
  });

  test('2 intersecting', () {
    // -======-
    // -----===
    const offsets = [Duration(seconds: 1), Duration(seconds: 5)];
    const durations = [Duration(seconds: 6), Duration(seconds: 3)];

    callWithPermutations2(offsets, durations, (offsets, durations) {
      expect(
        AlignMedia.getOverlappingsOfAny(
          offsets: offsets,
          durations: durations,
        ),
        const [
          MediaOverlapping(
            start: Duration(seconds: 5),
            end: Duration(seconds: 7),
            indices: [0, 1],
          ),
        ],
      );
    });
  });

  test('2 nesting', () {
    // -======-
    // ---===--
    const offsets = [Duration(seconds: 1), Duration(seconds: 3)];
    const durations = [Duration(seconds: 6), Duration(seconds: 3)];

    callWithPermutations2(offsets, durations, (offsets, durations) {
      expect(
        AlignMedia.getOverlappingsOfAny(
          offsets: offsets,
          durations: durations,
        ),
        const [
          MediaOverlapping(
            start: Duration(seconds: 3),
            end: Duration(seconds: 6),
            indices: [0, 1],
          ),
        ],
      );
    });
  });

  test('2 same', () {
    // -=====
    // -=====
    const offsets = [Duration(seconds: 1), Duration(seconds: 1)];
    const durations = [Duration(seconds: 5), Duration(seconds: 5)];

    callWithPermutations2(offsets, durations, (offsets, durations) {
      expect(
        AlignMedia.getOverlappingsOfAny(
          offsets: offsets,
          durations: durations,
        ),
        const [
          MediaOverlapping(
            start: Duration(seconds: 1),
            end: Duration(seconds: 6),
            indices: [0, 1],
          ),
        ],
      );
    });
  });

  test('3', () {
    const offsets = [
      Duration(seconds: 1),
      Duration(seconds: 5),
      Duration(seconds: 7),
    ];
    const durations = [
      Duration(seconds: 6),
      Duration(seconds: 3),
      Duration(seconds: 4),
    ];

    expect(
      () => AlignMedia.getOverlappingsOfAny(
        offsets: offsets,
        durations: durations,
      ),
      throwsUnimplementedError,
    );
  });
}
