#!/bin/bash

export API=24
export TARGET=arm64-v8a

export NDK_TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

export CC=$NDK_TOOLCHAIN/bin/aarch64-linux-android${API}-clang
export CXX=$NDK_TOOLCHAIN/bin/aarch64-linux-android${API}-clang++
export AR=$NDK_TOOLCHAIN/bin/llvm-ar
export AS=$NDK_TOOLCHAIN/bin/llvm-as
export LD=$NDK_TOOLCHAIN/bin/ld
export RANLIB=$NDK_TOOLCHAIN/bin/llvm-ranlib

export SYSROOT=$NDK_TOOLCHAIN/sysroot

export CFLAGS="--target=aarch64-linux-android${API} --sysroot=$SYSROOT"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="$CFLAGS"

export PATH=$NDK_TOOLCHAIN/bin:$PATH
