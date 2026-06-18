### 🎬 FFmpeg Android 13+ Build System (Expo Nitro Ready)

This repository builds a **custom FFmpeg single shared library (`libffmpeg.so`)** for:

- Android 13+ (API 33)
- arm64-v8a only
- React Native / Expo Nitro Modules
- Social media video editor apps (CapCut-style)

---

### 🚀 Features

### 🎥 Video Core

- libavcodec (encoders/decoders)
- libavformat (mux/demux)
- libavfilter (filters engine)
- libavutil (core utilities)
- libswscale (video scaling)
- libswresample (audio resampling)

---

### 🎞️ Video Codecs

### Software codecs
- H.264
- H.265
- VP8
- VP9
- MPEG-4 Part 2

### Hardware (Android MediaCodec)
- h264_mediacodec
- hevc_mediacodec
- vp8_mediacodec
- vp9_mediacodec

---

### 🎵 Audio Codecs

- AAC
- MP3
- FLAC
- Opus
- PCM/WAV

---

### 📦 Containers (Muxer/Demuxer)

- MP4
- MOV
- MKV
- WebM
- MP3
- M4A
- WAV
- FLAC

---

### 🎬 Video Filters

- scale
- crop
- overlay
- rotate
- fade
- zoompan
- trim (setpts)
- fps conversion

---

### 🔊 Audio Filters

- volume
- amix (audio mixing)
- aresample
- loudnorm
- fade in/out

---

### 🎬 Subtitle System (CapCut-style)

Powered by:

- libass
- FreeType
- HarfBuzz
- FriBidi
- FontConfig

### Features

- SRT / ASS / SSA / WebVTT
- Burn subtitles into video
- Font size control
- Font color control
- Outline / stroke
- Shadow support
- Positioning (x/y)
- Multi-line subtitles
- RTL support (Urdu, Arabic, Persian, Hebrew)
- Unicode support

---

### ⚡ Android Hardware Acceleration

- MediaCodec H.264 encode/decode
- MediaCodec H.265 encode/decode
- VP8/VP9 hardware decode (device dependent)
- Low CPU export mode

---

### 🧠 Architecture Overview

```

GitHub Actions
↓
Configs (feature flags)
↓
Validate Config
↓
Build Dependencies
(libass, freetype, harfbuzz, fribidi, fontconfig)
↓
Build FFmpeg
↓
Merge all libs
↓
libffmpeg.so
↓
Expo Nitro Module

```

---

### 📁 Repository Structure

```

.github/workflows/android.yml

configs/
ffmpeg.conf
codecs.conf
containers.conf
filters.conf
subtitles.conf

scripts/
common.sh
build.sh
build_deps.sh
build_ffmpeg.sh
validate_config.sh

output/

````

---

### 🏗️ Build Instructions

### 1. Clone repo

```bash
git clone https://github.com/your-org/ffmpeg-android-builder
cd ffmpeg-android-builder
````

---

### 2. Add Android NDK

GitHub Actions handles it automatically, or locally:

```bash
export NDK=/path/to/android-ndk
```

---

### 3. Run build

```bash
bash scripts/build.sh
```

---

### 4. Output

```
output/libs/libffmpeg.so
output/ffmpeg
output/ffprobe
```

---

### 🚀 GitHub Actions Build

### Trigger build:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### Output:

* GitHub Release
* Artifact:

  ```
  ffmpeg-android-arm64-v8a.tar.gz
  ```

---

### 📱 Expo Nitro Integration

Use this `.so` inside your native module:

```ts
import { NativeModule } from 'react-native';

export class FFmpegModule extends NativeModule {
  execute(command: string): Promise<string>;
}
```

---

### 🎬 Example Use Cases

### Trim video

```bash
ffmpeg -i input.mp4 -ss 00:00:05 -t 10 output.mp4
```

---

### Burn subtitles

```bash
ffmpeg -i input.mp4 -vf subtitles=sub.srt output.mp4
```

---

### Multi audio track export

```bash
ffmpeg -i video.mp4 -i audio2.aac -map 0 -map 1 output.mp4
```

---

### ⚙️ Configuration System

You can enable/disable features in:

```
configs/*.conf
```

Example:

```bash
CODEC_X264=no
ENABLE_LIBASS=yes
ENABLE_MEDIACODEC=yes
```

---

### 🧠 Design Philosophy

This system is designed for:

* High-performance mobile video editing
* Minimal runtime dependencies
* Single `.so` deployment
* Expo + React Native compatibility
* CapCut-style editing features

---

### ⚠️ Important Notes

* Android 13+ only
* arm64-v8a only
* MediaCodec preferred for encoding
* x264/x265 optional (disabled by default)
* libass required for advanced subtitles

---

### 🚀 Future Upgrades

* AV1 encoding (SVT-AV1)
* GPU filters (Vulkan/OpenCL)
* AI subtitle generation
* Real-time preview engine
* Timeline-based rendering API

---

### 🎯 Final Output

```
libffmpeg.so
```

A **single unified multimedia engine** for:

* Video editing
* Audio processing
* Subtitle rendering
* Social media export pipelines

---

### 🧠 Summary

This is not just FFmpeg.

This is:

> 🎬 A custom video editing engine for React Native / Expo Nitro

built on top of FFmpeg + MediaCodec + libass stack.

---