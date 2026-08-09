#!/bin/bash

set -e

# ==========================================
# LOAD ENVIRONMENT
# ==========================================

source scripts/common.sh

log "BUILDING DEPENDENCIES (libass stack)"

bash scripts/prepare_sources.sh

# ==========================================
# INSTALL PREFIX
# ==========================================

DEPS_PREFIX="$PROJECT_ROOT/deps/android/$ABI"
mkdir -p "$DEPS_PREFIX"

export PREFIX="$DEPS_PREFIX"

# ==========================================
# PATHS
# ==========================================

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR=
export PATH="$PREFIX/bin:$PATH"

# ==========================================
# GENERIC CONFIGURE FLAGS
# ==========================================

CONFIGURE_FLAGS="\
--host=$HOST \
--prefix=$PREFIX \
--enable-static \
--disable-shared"

MESON_CROSS_FILE="$PROJECT_ROOT/build/meson-$ABI.ini"
mkdir -p "$(dirname "$MESON_CROSS_FILE")"

MESON_COMMON_ARGS="'--target=${HOST}${TARGET_API}', '--sysroot=${SYSROOT}'"
if [ "$ENABLE_LTO" = "yes" ]; then
  MESON_COMMON_ARGS="$MESON_COMMON_ARGS, '-flto'"
fi

cat > "$MESON_CROSS_FILE" <<EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
strip = '$STRIP'
pkg-config = 'pkg-config'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = '$CPU'
endian = 'little'

[properties]
c_args = [$MESON_COMMON_ARGS]
cpp_args = [$MESON_COMMON_ARGS]
c_link_args = [$MESON_COMMON_ARGS]
cpp_link_args = [$MESON_COMMON_ARGS]
EOF

# ==========================================
# 0. EXPAT (FontConfig dependency)
# ==========================================

log "Building Expat"

cd "$PROJECT_ROOT/ffmpeg_sources/expat"

./configure $CONFIGURE_FLAGS

make -j$(nproc)
make install

check_error "Expat build"

# ==========================================
# 1. FREETYPE
# ==========================================

log "Building FreeType"

cd "$PROJECT_ROOT/ffmpeg_sources/freetype"

./configure $CONFIGURE_FLAGS \
  --without-png \
  --without-harfbuzz \
  --without-bzip2 \
  --without-brotli

make -j$(nproc)
make install

check_error "FreeType build"

# ==========================================
# 2. HARFBUZZ
# ==========================================

log "Building HarfBuzz"

cd "$PROJECT_ROOT/ffmpeg_sources/harfbuzz"

rm -rf build
meson setup build \
  --cross-file "$MESON_CROSS_FILE" \
  --prefix="$PREFIX" \
  --buildtype=release \
  --default-library=static \
  -Dglib=disabled \
  -Dgobject=disabled \
  -Dintrospection=disabled \
  -Ddocs=disabled \
  -Dtests=disabled \
  -Dbenchmark=disabled \
  -Dfreetype=enabled

ninja -C build
ninja -C build install

check_error "HarfBuzz build"

# ==========================================
# 3. FRIBIDI
# ==========================================

log "Building FriBidi"

cd "$PROJECT_ROOT/ffmpeg_sources/fribidi"

rm -rf build
meson setup build \
  --cross-file "$MESON_CROSS_FILE" \
  --prefix="$PREFIX" \
  --buildtype=release \
  --default-library=static \
  -Ddocs=false \
  -Dtests=false

ninja -C build
ninja -C build install

check_error "FriBidi build"

# ==========================================
# 4. FONTCONFIG
# ==========================================

log "Building FontConfig"

cd "$PROJECT_ROOT/ffmpeg_sources/fontconfig"

./configure $CONFIGURE_FLAGS \
  --with-expat="$PREFIX" \
  --with-add-fonts=/system/fonts \
  --disable-docs \
  --disable-tests \
  --without-uuid

make -j$(nproc)
make install

check_error "FontConfig build"

# ==========================================
# 5. LIBASS
# ==========================================

log "Building libass"

cd "$PROJECT_ROOT/ffmpeg_sources/libass"

./configure $CONFIGURE_FLAGS \
  --enable-harfbuzz \
  --enable-fontconfig \
  --disable-require-system-font-provider

make -j$(nproc)
make install

check_error "libass build"

# ==========================================
# 6. X264 (H.264 software encoder)
# ==========================================

if [ "$ENABLE_X264" = "yes" ] || [ "$CODEC_X264" = "yes" ]; then
  log "Building x264"

  cd "$PROJECT_ROOT/ffmpeg_sources/x264"

  make distclean || true

  CC="$CC" \
  AR="$AR" \
  RANLIB="$RANLIB" \
  STRIP="$STRIP" \
  ./configure \
    --host="$ARCH-linux" \
    --prefix="$PREFIX" \
    --sysroot="$SYSROOT" \
    --enable-static \
    --enable-pic \
    --disable-cli \
    --disable-opencl \
    --extra-cflags="$CFLAGS"

  make -j$(nproc)
  make install

  check_error "x264 build"
fi

# ==========================================
# 7. X265 (H.265 / HEVC software encoder)
# ==========================================

if [ "$ENABLE_X265" = "yes" ] || [ "$CODEC_X265" = "yes" ]; then
  log "Building x265"

  cd "$PROJECT_ROOT/ffmpeg_sources/x265"

  rm -rf build-native build

  env -u CC -u CXX -u CFLAGS -u CXXFLAGS -u LDFLAGS \
  cmake -S source -B build-native \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_HOST_SYSTEM_NAME=Linux \
    -DCMAKE_HOST_SYSTEM_PROCESSOR=x86_64 \
    -DNATIVE_BUILD=ON \
    -DENABLE_SHARED=OFF \
    -DENABLE_CLI=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_ASSEMBLY=OFF

  cmake --build build-native --parallel "$(nproc)"

  env -u CFLAGS -u CXXFLAGS -u LDFLAGS \
  cmake -S source -B build \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM="android-$TARGET_API" \
    -DCMAKE_HOST_SYSTEM_NAME=Linux \
    -DCMAKE_HOST_SYSTEM_PROCESSOR=x86_64 \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" \
    -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" \
    -DNATIVE_BUILD=OFF \
    -DENABLE_SHARED=OFF \
    -DENABLE_CLI=OFF \
    -DENABLE_PIC=ON \
    -DENABLE_TESTS=OFF \
    -DENABLE_ASSEMBLY=OFF

  cmake --build build --parallel "$(nproc)"
  cmake --install build

  check_error "x265 build"
fi

# ==========================================
# 8. LIBVPX (VP8 / VP9 software codecs)
# ==========================================

if [ "$ENABLE_LIBVPX" = "yes" ] || [ "$CODEC_LIBVPX" = "yes" ]; then
  log "Building libvpx"

  cd "$PROJECT_ROOT/ffmpeg_sources/libvpx"

  make distclean || true

  CC="$CC" \
  CXX="$CXX" \
  AR="$AR" \
  AS="$CC" \
  LD="$CXX" \
  NM="$NM" \
  STRIP="true" \
  ./configure \
    --target=arm64-android-gcc \
    --prefix="$PREFIX" \
    --enable-vp8 \
    --enable-vp9 \
    --enable-pic \
    --enable-static \
    --disable-shared \
    --disable-examples \
    --disable-tools \
    --disable-docs \
    --disable-unit-tests \
    --disable-install-bins \
    --extra-cflags="$CFLAGS"

  make -j$(nproc)
  make install

  check_error "libvpx build"
fi

# ==========================================
# DONE
# ==========================================

log "DEPENDENCIES BUILT SUCCESSFULLY"

echo "Installed to: $PREFIX"
