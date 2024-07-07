import 'dart:io';

/// Extracts audio from a media file.
Future<void> extractAudio({
  required String inputPath,
  required String outputPath,
  required bool reEncode,
}) async {
  final result = await Process.run('ffmpeg', [
    //
    '-i', inputPath,
    '-map', 'a',
    if (reEncode) ...['-q:a', '0'] else ...['-c:a', 'copy'],
    '-y', outputPath,
  ]);

  if (result.exitCode != 0) {
    final action = reEncode ? 're-encoding' : 'extracting';
    throw Exception('Error $action audio from $inputPath: ${result.stderr}');
  }
}
