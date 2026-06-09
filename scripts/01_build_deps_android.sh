set -e

mkdir -p src
cd src

# x264
git clone https://code.videolan.org/videolan/x264.git
cd x264
./configure --host=aarch64-linux-android --enable-static --disable-cli
make -j$(nproc)
make install
cd ..

# x265
git clone https://bitbucket.org/multicoreware/x265_git.git
cd x265_git/build/linux
cmake -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
-DANDROID_ABI=arm64-v8a \
-DANDROID_PLATFORM=24 ../../source
make -j$(nproc)
make install
cd ../../..

# libvpx
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx
./configure --target=arm64-android-gcc --enable-vp9
make -j$(nproc)
make install
cd ..
