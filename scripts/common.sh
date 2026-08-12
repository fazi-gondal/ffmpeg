#!/bin/bash

# ==========================================
# COMMON BUILD ENVIRONMENT
# ==========================================

set -e

# ==========================================
# PROJECT ROOT
# ==========================================

PROJECT_ROOT="$(pwd)"
CONFIG_DIR="$PROJECT_ROOT/configs"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
OUTPUT_DIR="$PROJECT_ROOT/output"

# ==========================================
# LOAD CONFIG FILES
# ==========================================

for conf in "$CONFIG_DIR"/*.conf; do
  [ -f "$conf" ] && sed -i 's/\r$//' "$conf" 2>/dev/null || true
done

source "$CONFIG_DIR/ffmpeg.conf"
source "$CONFIG_DIR/codecs.conf"
source "$CONFIG_DIR/containers.conf"
source "$CONFIG_DIR/filters.conf"
source "$CONFIG_DIR/subtitles.conf"

# ==========================================
# ANDROID NDK SETUP
# ==========================================

if [ -z "$NDK" ]; then
  echo "❌ ERROR: ANDROID NDK not found"
  exit 1
fi

TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64"

# ==========================================
# TARGET SETTINGS (ARM64-V8A)
# ==========================================

TARGET_API=$ANDROID_API

ARCH="aarch64"
CPU="armv8-a"
ABI="arm64-v8a"

HOST="aarch64-linux-android"

# ==========================================
# COMPILERS
# ==========================================

export CC="$TOOLCHAIN/bin/aarch64-linux-android${TARGET_API}-clang"
export CXX="$TOOLCHAIN/bin/aarch64-linux-android${TARGET_API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export STRIP="$TOOLCHAIN/bin/llvm-strip"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export NM="$TOOLCHAIN/bin/llvm-nm"

# ==========================================
# SYSROOT
# ==========================================

SYSROOT="$TOOLCHAIN/sysroot"

# ==========================================
# BASE FLAGS
# ==========================================

CFLAGS="--target=${HOST}${TARGET_API} --sysroot=${SYSROOT}"
CXXFLAGS="$CFLAGS"
LDFLAGS="--target=${HOST}${TARGET_API} --sysroot=${SYSROOT}"

# ==========================================
# OPTIMIZATION FLAGS
# ==========================================

if [ "$ENABLE_LTO" = "yes" ]; then
  CFLAGS="$CFLAGS -flto"
  LDFLAGS="$LDFLAGS -flto"
fi

# ==========================================
# EXPORT GLOBAL ENVIRONMENT
# ==========================================

export ARCH
export CPU
export ABI
export SYSROOT
export TARGET_API

export CFLAGS
export CXXFLAGS
export LDFLAGS

# ==========================================
# BUILD HELPERS
# ==========================================

log() {
  echo ""
  echo "=========================================="
  echo "$1"
  echo "=========================================="
}

check_error() {
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: $1 failed"
    exit 1
  fi
}

# ==========================================
# CLEAN OUTPUT
# ==========================================

mkdir -p "$OUTPUT_DIR"

echo "✅ Common build environment loaded"
echo "👉 Target: $ABI (API $ANDROID_API)"