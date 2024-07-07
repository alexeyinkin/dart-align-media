# Examples of using `align_media`

All examples require [ffmpeg](https://ffmpeg.org) installed and available in `$PATH`.

To run an example:

1. Clone this repository.
2. `cd example`
3. Run an example using a command specific to the example (see below).

## [replace_audio](lib/replace_audio.dart)

```dart
await AlignMedia.replaceAudio(
  audioPath: argv[0],
  videoPath: argv[1],
  outputPath: 'replaced.mov',
);
```

To run as a user:

```bash
dart run lib/replace_audio.dart media/audio.mp3 media/camera1.mov replaced.mov
```
