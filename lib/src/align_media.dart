import 'dart:io';
import 'dart:math';

import 'package:wav/wav.dart';

import 'align_result.dart';
import 'util.dart';

const _defaultDownsample = Duration(milliseconds: 10);

/// Contains static functions for manipulating media files.
abstract final class AlignMedia {
  /// Returns cross-correlated data for [paths].
  static Future<AlignResult> align(
    List<String> paths, {
    Duration downsample = _defaultDownsample,
  }) async {
    try {
      final wavs = await _getWavs(paths);
      final result = _alignWavs(wavs, downsample: downsample);
      await _deleteTempFiles(paths.length);
      return result;
      // ignore: avoid_catches_without_on_clauses
    } catch (ex) {
      await _deleteTempFiles(paths.length);
      rethrow;
    }
  }

  /// Returns the media type of [path].
  /// Throws an exception if it's not audio or video.
  static Future<MediaType> getMediaType(String path) async {
    final result = await Process.run('ffprobe', [
      //
      '-v', 'quiet',
      '-select_streams', 'v',
      '-show_streams',
      path,
    ]);

    if (result.exitCode != 0) {
      throw Exception('Not a media file: $path: ${result.stderr}');
    }

    // ignore: avoid_dynamic_calls
    return result.stdout.length > 0 ? MediaType.video : MediaType.audio;
  }

  /// Returns overlappings of segments represented by [offsets] and [durations].
  static List<MediaOverlapping> getOverlappingsOfAny({
    required List<Duration> offsets,
    required List<Duration> durations,
  }) {
    if (offsets.length != durations.length) {
      throw ArgumentError(
        'Offsets and durations must be of the same size, '
        '${offsets.length} and ${durations.length} given.',
      );
    }

    return switch (offsets.length) {
      0 => const [],
      1 => const [],
      2 => _getOverlappingsOf2(
          offset1: offsets[0],
          duration1: durations[0],
          offset2: offsets[1],
          duration2: durations[1],
        ),
      _ => throw UnimplementedError(),
    };
  }

  /// Replaces the audio in [videoPath] with [audioPath]
  /// and automatically aligns the audio using [align].
  static Future<void> replaceAudio({
    required String audioPath,
    required String videoPath,
    required String outputPath,
    Duration downsample = _defaultDownsample,
  }) async {
    final r = await align([audioPath, videoPath], downsample: downsample);

    final result = await Process.run('ffmpeg', [
      //
      '-i', audioPath,
      '-i', videoPath,
      '-filter_complex',
      '''
[0:a]atrim=start=${r.startOfMediaInOverlapping(0, 0).inSecondsDouble}:end=${r.endOfMediaInOverlapping(0, 0).inSecondsDouble},asetpts=PTS-STARTPTS[a];
[1:v]trim=start=${r.startOfMediaInOverlapping(1, 0).inSecondsDouble}:end=${r.endOfMediaInOverlapping(1, 0).inSecondsDouble},setpts=PTS-STARTPTS[v];
''',
      '-map', '[v]',
      '-map', '[a]',
      '-y', outputPath,
    ]);

    if (result.exitCode != 0) {
      throw Exception(
        'Error replacing sound with $audioPath in $videoPath: ${result.stderr}',
      );
    }
  }
}

Future<List<Wav>> _getWavs(List<String> paths) async {
  return Future.wait([
    for (int i = 0; i < paths.length; i++)
      _getWav(paths[i], _audioTempFileName(i)),
  ]);
}

String _audioTempFileName(int n) => 'audio_$n.wav';

Future<Wav> _getWav(String inputPath, String outputPath) async {
  await extractAudio(
    inputPath: inputPath,
    outputPath: outputPath,
    reEncode: false,
  );

  try {
    return await Wav.readFile(outputPath);
  } on Exception {
    await extractAudio(
      inputPath: inputPath,
      outputPath: outputPath,
      reEncode: true,
    );

    return Wav.readFile(outputPath);
  }
}

AlignResult _alignWavs(
  List<Wav> wavs, {
  required Duration downsample,
}) {
  final durations = [
    for (int i = 0; i < wavs.length; i++) wavs[i].durationDuration,
  ];

  final downsampled = _downsampleAll(wavs, sample: downsample);
  final offsets = _alignSignals(downsampled);

  final offsetDurations = [
    for (int i = 0; i < wavs.length; i++) downsample * offsets[i],
  ];

  final media = [
    for (int i = 0; i < wavs.length; i++)
      AlignMediaResult(
        duration: durations[i],
        offset: offsetDurations[i],
      ),
  ];

  return AlignResult(
    media: media,
    overlappingsOfAny: AlignMedia.getOverlappingsOfAny(
      offsets: offsetDurations,
      durations: durations,
    ),
  );
}

List<List<double>> _downsampleAll(List<Wav> wavs, {required Duration sample}) {
  return [
    for (final wav in wavs) _downsample(wav, sample: sample),
  ];
}

List<double> _downsample(Wav wav, {required Duration sample}) {
  final factor =
      (wav.samplesPerSecond * sample.inMicroseconds / 1000 / 1000).floor();

  final signal = wav.channels.first;

  final length = signal.length ~/ factor;
  final downsampled = List<double>.filled(length, 0);

  for (int i = 0; i < length; i++) {
    double sum = 0;
    for (int j = 0; j < factor; j++) {
      sum += signal[i * factor + j].abs();
    }
    downsampled[i] = sum;
  }

  return downsampled;
}

List<int> _alignSignals(List<List<double>> signals) {
  return switch (signals.length) {
    0 => const [],
    1 => const [0],
    2 => _alignSignals2(signals[0], signals[1]),
    _ => _alignSignalsOver2(signals),
  };
}

List<int> _alignSignals2(List<double> signal1, List<double> signal2) {
  double maxCorr = -double.infinity;
  int maxCorrOffset = 0;

  for (int offset = -signal2.length; offset < signal1.length; offset++) {
    final end = min(signal1.length, offset + signal2.length);
    double sum = 0;

    for (int i = max(offset, 0); i < end; i++) {
      sum += signal1[i] * signal2[i - offset];
    }

    if (sum > maxCorr) {
      maxCorr = sum;
      maxCorrOffset = offset;
    }
  }

  return maxCorrOffset > 0 ? [0, maxCorrOffset] : [-maxCorrOffset, 0];
}

List<int> _alignSignalsOver2(List<List<double>> signals) {
  throw UnimplementedError();
}

Future<void> _deleteTempFiles(int n) async {
  await Future.wait([
    for (int i = n; --i >= 0;) _deleteFileIfExists(File(_audioTempFileName(i))),
  ]);
}

Future<void> _deleteFileIfExists(File file) async {
  if (!file.existsSync()) {
    return;
  }

  await file.delete();
}

List<MediaOverlapping> _getOverlappingsOf2({
  required Duration offset1,
  required Duration duration1,
  required Duration offset2,
  required Duration duration2,
}) {
  final end1 = offset1 + duration1;
  final end2 = offset2 + duration2;

  if (offset1 >= end2) return const [];
  if (offset2 >= end1) return const [];

  return [
    MediaOverlapping(
      start: _maxDuration(offset1, offset2),
      end: _minDuration(end1, end2),
      indices: const [0, 1],
    ),
  ];
}

Duration _maxDuration(Duration a, Duration b) {
  return a > b ? a : b;
}

Duration _minDuration(Duration a, Duration b) {
  return a < b ? a : b;
}

extension on Duration {
  double get inSecondsDouble => inMicroseconds / 1000 / 1000;
}

extension on Wav {
  Duration get durationDuration => Duration(
        microseconds: (duration * Duration.microsecondsPerSecond).floor(),
      );
}
