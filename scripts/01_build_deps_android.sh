echo "Building x264..."

git clone https://code.videolan.org/videolan/x264.git
cd x264

export CROSS_PREFIX=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-

./configure \
  --prefix=$PREFIX \
  --host=aarch64-linux-android \
  --cross-prefix=$CROSS_PREFIX \
  --enable-static \
  --disable-cli \
  --extra-cflags="-march=armv8-a+simd -O3"

make -j$(nproc)
make install

cd ..
