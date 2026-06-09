#!/usr/bin/env bash

# This script directly configures a slimmed down, single merged libffmpeg.so binary file
FAM_ARGS+=(
  --disable-everything
  --enable-gpl
  --enable-version3
  --enable-shared
  --disable-static
  --disable-programs
  
  # External Encoders/Decoders requested
  --enable-libx264
  --enable-libx265
  --enable-libvpx
  --enable-libmp3lame
  --enable-libopus
  --enable-libflac
  --enable-libass
  
  # Surgical component optimization rules
  --enable-encoder=libx264,libx265,libvpx_vp8,libvpx_vp9,libmp3lame,libopus,flac
  --enable-decoder=h264,hevc,vp8,vp9,mp3,opus,flac
  --enable-muxer=mp4,mkv,webm,mp3,ogg,flac
  --enable-demuxer=mov,matroska,mp3,ogg,flac
  --enable-protocol=file
  --enable-filter=scale,vflip,hflip,transpose,ass
)
