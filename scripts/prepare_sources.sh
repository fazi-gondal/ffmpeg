#!/bin/bash

set -e

source scripts/common.sh

log "PREPARING SOURCE DEPENDENCIES"

SOURCES_DIR="$PROJECT_ROOT/ffmpeg_sources"
mkdir -p "$SOURCES_DIR"

download_source() {
  local name="$1"
  local version="$2"
  local url="$3"
  local archive="$SOURCES_DIR/${name}-${version}.tar.${url##*.tar.}"
  local dest="$SOURCES_DIR/$name"

  if [ -d "$dest" ]; then
    echo "$name already exists: $dest"
    return
  fi

  echo "Downloading $name $version"
  curl -L --fail --retry 3 -o "$archive" "$url"

  mkdir -p "$dest"
  tar -xf "$archive" -C "$dest" --strip-components=1
}

download_source "expat" "2.6.2" "https://github.com/libexpat/libexpat/releases/download/R_2_6_2/expat-2.6.2.tar.xz"
download_source "freetype" "2.13.2" "https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.xz"
download_source "harfbuzz" "8.5.0" "https://github.com/harfbuzz/harfbuzz/releases/download/8.5.0/harfbuzz-8.5.0.tar.xz"
download_source "fribidi" "1.0.15" "https://github.com/fribidi/fribidi/releases/download/v1.0.15/fribidi-1.0.15.tar.xz"
download_source "fontconfig" "2.15.0" "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.xz"
download_source "libass" "0.17.1" "https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz"
download_source "ffmpeg" "6.1.1" "https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.xz"

log "SOURCES READY"
