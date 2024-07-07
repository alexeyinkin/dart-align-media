import 'dart:io';

import 'package:align_media/align_media.dart';

Future<void> main(List<String> argv) async {
  if (argv.length < 3) {
    stderr.write(
      'Usage: dart run lib/replace_audio.dart audio.mp3 video.mov output.mov',
    );
    exit(64);
  }

  await AlignMedia.replaceAudio(
    audioPath: argv[0],
    videoPath: argv[1],
    outputPath: argv[2],
  );
}
