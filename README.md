# FFmpeg Android 13+ Builder for Expo / React Native

This repository builds a custom FFmpeg Android package for Expo Nitro Modules, React Native native modules, and mobile video editor apps.

The default target is:

- Android API 33+
- ABI: `arm64-v8a`
- Architecture: `aarch64`
- Output: single shared library `libffmpeg.so`
- Optional runtime tools: `ffmpeg` and `ffprobe`
- CI: GitHub Actions with automatic artifact and GitHub Release upload

## What Gets Built

The build produces:

```text
output/
  libs/
    libffmpeg.so
  ffmpeg
  ffprobe
  build-info.txt
```

GitHub Actions also creates:

```text
release/
  ffmpeg-android-arm64-v8a.tar.gz
  libffmpeg.so
  build-info.txt
```

The release package contains the complete `output/` directory.

## Core FFmpeg Libraries

The final shared library is assembled from static FFmpeg libraries and selected subtitle/font dependencies:

- `libavcodec`
- `libavformat`
- `libavfilter`
- `libavdevice`
- `libavutil`
- `libswscale`
- `libswresample`
- `libass`
- `fontconfig`
- `freetype`
- `harfbuzz`
- `fribidi`
- `expat`

The final link step uses Android `clang`, permits FFmpeg internal duplicate helper symbols when flattening static archives into one `.so`, and hides archive symbols from the exported library surface.

## Hardware Acceleration

MediaCodec is enabled for Android hardware acceleration:

### Hardware Decoders

- `h264_mediacodec`
- `hevc_mediacodec`
- `vp8_mediacodec`
- `vp9_mediacodec`

### Hardware Encoders

- `h264_mediacodec`
- `hevc_mediacodec`

VP8 and VP9 MediaCodec support is decode-only in the current build script.

## Software Codecs

The config enables FFmpeg native codec support for common editor formats:

### Video Codecs

- H.264
- H.265 / HEVC
- VP8
- VP9
- MPEG-4 Part 2
- MJPEG

### Audio Codecs

- AAC
- MP3
- FLAC
- Opus
- PCM / WAV

### External Codecs

Enabled by default:

- x264 H.264 encoder: `CODEC_X264=yes`, `ENABLE_X264=yes`
- x265 H.265 / HEVC encoder: `CODEC_X265=yes`, `ENABLE_X265=yes`
- libvpx VP8 / VP9 encoder and decoder: `CODEC_LIBVPX=yes`, `ENABLE_LIBVPX=yes`

Configured as optional and disabled by default:

- AV1: `CODEC_AV1=no`, `ENABLE_AV1=no`
- SVT-AV1: `CODEC_SVTAV1=no`, `ENABLE_SVTAV1=no`
- rav1e: `CODEC_RAV1E=no`
- Theora: `CODEC_THEORA=no`
- Vorbis: `CODEC_VORBIS=no`
- Speex: `CODEC_SPEEX=no`
- ALAC: `CODEC_ALAC=no`
- FDK-AAC: `CODEC_FDK_AAC=no`

The build script only enables external codec libraries when their flags are set to `yes`. x264, x265, and libvpx are built as Android static dependencies before FFmpeg configure runs, so FFmpeg can resolve their pkg-config files and static archives.

Note: x264 and x265 are GPL-licensed. Keeping `ENABLE_X264=yes` and `ENABLE_X265=yes` means this FFmpeg build is a GPL build.

## Containers

### Muxers

Enabled by config:

- MP4
- MOV
- MKV / Matroska
- WebM
- MP3
- M4A
- WAV
- FLAC

The FFmpeg configure script currently enables:

- `mp4`
- `matroska`
- `mov`
- `webm`
- `mp3`
- `wav`
- `flac`

### Demuxers

Enabled by config:

- MP4
- MOV
- MKV / Matroska
- WebM
- MP3
- M4A
- WAV
- FLAC

The FFmpeg configure script currently enables:

- `mp4`
- `matroska`
- `mov`
- `webm`
- `mp3`
- `wav`
- `flac`

### Optional Containers Disabled by Default

- AVI
- FLV
- 3GP
- MPEG-TS
- OGG
- MXF
- DASH
- HLS
- Smooth Streaming

## Protocols

Enabled protocols:

- `file`
- `http`
- `https`

## Filters

### Video Filters

Enabled or configured for the editor pipeline:

- `scale`
- `crop`
- `overlay`
- `rotate`
- `fade`
- `zoompan`
- `subtitles`
- flip support in config
- fps conversion in config
- setpts timeline support in config
- framerate conversion in config
- brightness/contrast support in config
- hue/saturation support in config
- gaussian blur support in config

### Audio Filters

Configured for audio editing:

- `volume`
- `amix`
- `aresample`
- `loudnorm`
- audio trim
- audio fade
- multi-track audio support

### Text and Subtitle Filters

- `subtitles`
- ASS subtitle rendering through libass
- styled subtitles
- custom font rendering
- drawbox support in config
- drawtext support in config

## Subtitle and Text Rendering Stack

The build includes a full libass subtitle stack:

- `libass`
- `FreeType`
- `HarfBuzz`
- `FriBidi`
- `FontConfig`
- `Expat`

Supported subtitle features:

- SRT
- ASS
- SSA
- WebVTT
- burn-in subtitles
- styled subtitles
- font size control
- font color control
- font style control
- outline / stroke
- shadow
- text background
- x/y positioning
- alignment
- multi-line captions
- timed subtitles
- UTF-8 text
- RTL scripts such as Urdu, Arabic, Persian, and Hebrew
- LTR scripts
- bidirectional text shaping
- custom fonts
- system fonts
- font cache

Default subtitle renderer:

```text
SUBTITLE_RENDER_MODE=libass
```

Default font:

```text
DEFAULT_FONT=Roboto
```

## Multi-Stream Editing Features

Enabled by config:

- multiple audio tracks
- multiple video streams
- multiple subtitle streams
- metadata support
- chapters support
- faststart MP4 support
- subtitle burn-in
- frame accurate editing flag
- timeline sync flag
- sticker overlay flag
- image overlay flag
- speed control flag

## Disabled Advanced Features

These features are present as future config switches but disabled by default:

- AV1 encoding
- SVT-AV1
- Vulkan
- OpenCL
- CUDA
- VAAPI
- Intel QSV
- VideoToolbox
- Dolby Vision
- HDR10
- HDR10+
- xfade transitions
- unsharp
- chromakey
- advanced keying
- GL transform
- Vulkan filters
- subtitle animation
- word-level karaoke timing
- AI subtitle sync
- translation subtitles
- realtime subtitle editing

## Source Dependencies

The build downloads and prepares these source packages:

- FFmpeg 8.1.2
- Expat 2.6.2
- FreeType 2.13.2
- HarfBuzz 8.5.0
- FriBidi 1.0.15
- FontConfig 2.15.0
- libass 0.17.1
- x264 stable branch
- x265 4.1
- libvpx 1.15.2

Sources are prepared under:

```text
ffmpeg_sources/
```

Android dependency outputs are installed under:

```text
deps/android/arm64-v8a/
```

## GitHub Actions

Workflow file:

```text
.github/workflows/android.yml
```

### Triggers

The workflow runs on:

- manual dispatch from the GitHub Actions tab
- pushed tags matching `v*`

### Release Upload Behavior

Tag builds publish a normal GitHub Release for the tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Manual builds publish or update a normal release named:

```text
latest
```

Manual builds also move the `latest` git tag to the current commit before publishing. That keeps GitHub's automatic source archives up to date:

- `Source code (zip)`
- `Source code (tar.gz)`

Both tag builds and manual builds are marked as the latest GitHub Release, not as prereleases.

Release assets:

- `ffmpeg-android-arm64-v8a.tar.gz`
- `libffmpeg.so`
- `build-info.txt`

Release notes are generated by the workflow and include the FFmpeg version, Node.js runtime, x264 support, MediaCodec support, and subtitle stack.

The workflow requires:

```yaml
permissions:
  contents: write
```

This is already configured so `softprops/action-gh-release` can create or update releases.

## Local Build

Install Android NDK r26d or compatible, then set:

```bash
export NDK=/path/to/android-ndk-r26d
```

Run:

```bash
bash scripts/build.sh
```

Validation only:

```bash
bash scripts/validate_config.sh
```

Build dependencies only:

```bash
bash scripts/build_deps.sh
```

Build FFmpeg only:

```bash
bash scripts/build_ffmpeg.sh
```

## Configuration Files

Feature flags live in:

```text
configs/
  ffmpeg.conf
  codecs.conf
  containers.conf
  filters.conf
  subtitles.conf
```

Important defaults:

```bash
FFMPEG_VERSION=8.1.2
ANDROID_API=33
TARGET_ARCH=aarch64
TARGET_ABI=arm64-v8a
ENABLE_MEDIACODEC=yes
ENABLE_AVDEVICE=yes
ENABLE_LIBASS=yes
ENABLE_FREETYPE=yes
ENABLE_HARFBUZZ=yes
ENABLE_FRIBIDI=yes
ENABLE_FONTCONFIG=yes
ENABLE_X264=yes
ENABLE_X265=yes
ENABLE_LIBVPX=yes
BUILD_FFMPEG=yes
BUILD_FFPROBE=yes
OUTPUT_SINGLE_SO=yes
OUTPUT_NAME=libffmpeg.so
ENABLE_LTO=yes
STRIP_BINARIES=yes
```

## Expo / React Native Integration

Use `output/libs/libffmpeg.so` in your Android native module or Expo Nitro module.

Example TypeScript surface:

```ts
import { NativeModule } from 'react-native';

export class FFmpegModule extends NativeModule {
  execute(command: string): Promise<string>;
}
```

Typical app workflows:

- video trim
- crop / resize / rotate
- overlay images or video
- burn subtitles into video
- render styled ASS captions
- process multi-audio exports
- mix audio tracks
- normalize volume
- generate social media MP4/WebM outputs

## Example Commands

Trim video:

```bash
ffmpeg -i input.mp4 -ss 00:00:05 -t 10 output.mp4
```

Burn subtitles:

```bash
ffmpeg -i input.mp4 -vf subtitles=subtitles.srt output.mp4
```

Overlay an image:

```bash
ffmpeg -i video.mp4 -i sticker.png -filter_complex overlay=20:20 output.mp4
```

Mix audio tracks:

```bash
ffmpeg -i video.mp4 -i music.aac -filter_complex amix=inputs=2 output.mp4
```

Export WebM:

```bash
ffmpeg -i input.mp4 output.webm
```

## Notes

- The default build is optimized for Android 13+ and `arm64-v8a`.
- MediaCodec support depends on the runtime Android device.
- x264 is enabled and built by default for the `libx264` H.264 software encoder.
- x265 is enabled and built by default for the `libx265` H.265 / HEVC software encoder.
- libvpx is enabled and built by default for VP8 / VP9 software encoding and decoding.
- libopus and libmp3lame are not built unless explicitly enabled and added to the dependency build.
- The output is intentionally packaged as one shared library for easier mobile integration.
- The CI build also uploads a normal Actions artifact, so release assets and workflow artifacts are both available.
