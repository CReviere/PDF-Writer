#!/usr/bin/env bash

mkdir build && cd build
cmake -G "Xcode" -DPDFHUMMUS_NO_AES=true ..

for i in Debug Release; do
  /usr/bin/xcodebuild -project PDFHUMMUS.xcodeproj \
    -configuration $i build
done
