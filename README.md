# usage

## `align`: Cross-correlate media files using their audio tracks

```dart
final result = await AlignMedia.align([path1, path2]);
```

See the reference for the fields of `AlignResult`.

## `replaceAudio`: Replace the audio track in a video with a given audio, auto-align

```dart
await AlignMedia.replaceAudio(
  audioPath: 'audio.mp3',
  videoPath: 'video.mov',
  outputPath: 'replaced.mov',
);
```
