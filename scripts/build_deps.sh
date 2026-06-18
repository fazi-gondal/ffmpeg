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
# PATHS & COMPILER FLAGS
# ==========================================

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PATH="$PREFIX/bin:$PATH"

export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# ==========================================
# DOWNLOAD & EXTRACT HELPERS
# ==========================================

SOURCES_DIR="$PROJECT_ROOT/ffmpeg_sources"
mkdir -p "$SOURCES_DIR"

download_and_extract() {
  local url="$1"
  local archive_name="$2"
  local folder_name="$3"
  local target_name="$4"
  
  if [ ! -d "$SOURCES_DIR/$target_name" ]; then
    log "Downloading $url..."
    wget -q --show-progress -O "$SOURCES_DIR/$archive_name" "$url"
    
    log "Extracting $archive_name..."
    tar -xf "$SOURCES_DIR/$archive_name" -C "$SOURCES_DIR"
    
    mv "$SOURCES_DIR/$folder_name" "$SOURCES_DIR/$target_name"
    rm -f "$SOURCES_DIR/$archive_name"
    log "Successfully prepared $target_name"
  else
    log "$target_name already prepared"
  fi
}

# Download all sources
download_and_extract "https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz" "expat-2.5.0.tar.gz" "expat-2.5.0" "expat"
download_and_extract "https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.gz" "freetype-2.13.2.tar.gz" "freetype-2.13.2" "freetype"
download_and_extract "https://github.com/harfbuzz/harfbuzz/releases/download/8.3.0/harfbuzz-8.3.0.tar.xz" "harfbuzz-8.3.0.tar.xz" "harfbuzz-8.3.0" "harfbuzz"
download_and_extract "https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz" "fribidi-1.0.13.tar.xz" "fribidi-1.0.13" "fribidi"
download_and_extract "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.gz" "fontconfig-2.14.2.tar.gz" "fontconfig-2.14.2" "fontconfig"
download_and_extract "https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz" "libass-0.17.1.tar.xz" "libass-0.17.1" "libass"
download_and_extract "https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.xz" "ffmpeg-6.1.1.tar.xz" "ffmpeg-6.1.1" "ffmpeg"

# ==========================================
# GENERIC CONFIGURE FLAGS
# ==========================================

CONFIGURE_FLAGS="\
--host=$HOST \
--prefix=$PREFIX \
--enable-static \
--disable-shared"

# ==========================================
# 0. EXPAT (required by FontConfig)
# ==========================================

log "Building Expat"

cd "$SOURCES_DIR/expat"

./configure $CONFIGURE_FLAGS

make -j$(nproc)
make install

check_error "Expat build"

# ==========================================
# 1. FREETYPE
# ==========================================

log "Building FreeType"

cd "$SOURCES_DIR/freetype"

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

cd "$SOURCES_DIR/harfbuzz"

# Generate meson cross file dynamically
cat > meson-cross.txt <<EOF
[binaries]
c = '$(echo $CC | cut -d' ' -f1)'
cpp = '$(echo $CXX | cut -d' ' -f1)'
ar = '$AR'
strip = '$STRIP'
pkgconfig = 'pkg-config'

[built-in options]
c_args = [$(echo $CFLAGS | sed "s/ /', '/g" | sed "s/^/'/" | sed "s/$/'/")]
cpp_args = [$(echo $CXXFLAGS | sed "s/ /', '/g" | sed "s/^/'/" | sed "s/$/'/")]
c_link_args = [$(echo $LDFLAGS | sed "s/ /', '/g" | sed "s/^/'/" | sed "s/$/'/")]
cpp_link_args = [$(echo $LDFLAGS | sed "s/ /', '/g" | sed "s/^/'/" | sed "s/$/'/")]

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8-a'
endian = 'little'
EOF

rm -rf build
meson setup build \
  --cross-file meson-cross.txt \
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

cd "$SOURCES_DIR/fribidi"

./configure $CONFIGURE_FLAGS

make -j$(nproc)
make install

check_error "FriBidi build"

# ==========================================
# 4. FONTCONFIG
# ==========================================

log "Building FontConfig"

cd "$SOURCES_DIR/fontconfig"

./configure $CONFIGURE_FLAGS \
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

cd "$SOURCES_DIR/libass"

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
