#!/bin/bash

set -e

# ==========================================
# LOAD ENVIRONMENT
# ==========================================

source scripts/common.sh

log "BUILDING DEPENDENCIES (libass stack)"

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
export PATH="$PREFIX/bin:$PATH"

# ==========================================
# GENERIC CONFIGURE FLAGS
# ==========================================

CONFIGURE_FLAGS="\
--host=$HOST \
--prefix=$PREFIX \
--enable-static \
--disable-shared"

# ==========================================
# 1. FREETYPE
# ==========================================

log "Building FreeType"

cd "$PROJECT_ROOT/ffmpeg_sources/freetype"

./configure $CONFIGURE_FLAGS \
  --without-png \
  --without-harfbuzz

make -j$(nproc)
make install

check_error "FreeType build"

# ==========================================
# 2. HARFBUZZ
# ==========================================

log "Building HarfBuzz"

cd "$PROJECT_ROOT/ffmpeg_sources/harfbuzz"

meson setup build \
  --prefix=$PREFIX \
  --buildtype=release \
  -Dtests=disabled \
  -Dbenchmark=disabled

ninja -C build
ninja -C build install

check_error "HarfBuzz build"

# ==========================================
# 3. FRIBIDI
# ==========================================

log "Building FriBidi"

cd "$PROJECT_ROOT/ffmpeg_sources/fribidi"

./configure $CONFIGURE_FLAGS

make -j$(nproc)
make install

check_error "FriBidi build"

# ==========================================
# 4. FONTCONFIG
# ==========================================

log "Building FontConfig"

cd "$PROJECT_ROOT/ffmpeg_sources/fontconfig"

./configure $CONFIGURE_FLAGS \
  --disable-docs \
  --disable-tests

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
  --enable-fontconfig

make -j$(nproc)
make install

check_error "libass build"

# ==========================================
# DONE
# ==========================================

log "DEPENDENCIES BUILT SUCCESSFULLY"

echo "Installed to: $PREFIX"