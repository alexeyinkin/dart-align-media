import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// The result of running cross-correlation on media files.
class AlignResult {
  /// Attributes of cross-correlation of each media.
  final List<AlignMediaResult> media;

  /// Overlappings of any two or more media files.
  final List<MediaOverlapping> overlappingsOfAny;

  /// The result of running cross-correlation on media files.
  const AlignResult({
    required this.media,
    required this.overlappingsOfAny,
  });

  /// Returns at which offset within the media #[mediaIndex]
  /// the beginning of the overlapping #[overlappingIndex] is.
  ///
  /// Use as 'start' argument to 'trim' complex_filter of ffmpeg.
  Duration startOfMediaInOverlapping(int mediaIndex, int overlappingIndex) {
    return overlappingsOfAny[overlappingIndex].start - media[mediaIndex].offset;
  }

  /// Returns at which offset within the media #[mediaIndex]
  /// the end of the overlapping #[overlappingIndex] is.
  ///
  /// Use as 'end' argument to 'trim' complex_filter of ffmpeg.
  Duration endOfMediaInOverlapping(int mediaIndex, int overlappingIndex) {
    return overlappingsOfAny[overlappingIndex].end - media[mediaIndex].offset;
  }
}

/// The properties of a media cross-correlated with others in [AlignResult].
class AlignMediaResult {
  /// The full duration of the media file.
  final Duration duration;

  /// The offset of the beginning of this media from the beginning
  /// of the earliest of the cross-correlated media.
  final Duration offset;

  /// The properties of a media cross-correlated with others in [AlignResult].
  const AlignMediaResult({
    required this.duration,
    required this.offset,
  });
}

/// Overlapping of media files.
///
/// All timestamps are relative to the beginning of the earliest
/// of the cross-correlated media.
@immutable
class MediaOverlapping {
  /// Starting point of this overlapping.
  final Duration start;

  /// Ending point of this overlapping.
  final Duration end;

  /// Indices of the input media files in this overlapping.
  final List<int> indices;

  /// Overlapping of media files.
  ///
  /// All timestamps are relative to the beginning of the earliest
  /// of the cross-correlated media.
  const MediaOverlapping({
    required this.start,
    required this.end,
    required this.indices,
  });

  @override
  bool operator ==(Object other) {
    return other is MediaOverlapping &&
        start == other.start &&
        end == other.end &&
        const ListEquality().equals(indices, other.indices);
  }

  @override
  int get hashCode => Object.hash(start, end, indices);
}

/// A media type.
enum MediaType {
  /// Audio.
  audio,

  /// Video.
  video,
}
