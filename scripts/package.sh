set -e

PLATFORM=$1

mkdir -p release/$PLATFORM

if [ "$PLATFORM" = "android" ]; then
  cp -r build/android/lib/*.so release/android/
fi

if [ "$PLATFORM" = "ios" ]; then
  xcodebuild -create-xcframework \
  -library build/ios/lib/libavcodec.a \
  -library build/ios/lib/libavformat.a \
  -library build/ios/lib/libavfilter.a \
  -library build/ios/lib/libavutil.a \
  -library build/ios/lib/libswscale.a \
  -library build/ios/lib/libswresample.a \
  -output release/ios/FFmpeg.xcframework
fi
