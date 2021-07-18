#!/bin/bash
set -eu

# # >> workaround for https://github.com/sensuikan1973/pedax/pull/155#issuecomment-882051791
# flutter clean
# echo $PUB_CACHE/git
# ls $PUB_CACHE/git
# rm -rf $PUB_CACHE/git
# flutter pub get
# flutter build windows --release
# # << workaround

ls $PUB_CACHE/git
flutter pub pub cache repair
flutter pub get
ls $PUB_CACHE/git/flutter-desktop-embedding-e48abe7c3e9ebfe0b81622167c5201d4e783bb81/plugins

flutter pub run msix:create

# For developers which want to run `.exe` directory, repack ***.dll.
# See: https://flutter.dev/desktop#building-your-own-zip-file-for-windows
# REF: https://github.com/sensuikan1973/pedax/pull/71#issuecomment-798849250
# REF: https://github.com/sensuikan1973/pedax/pull/83#issuecomment-803240876
system32_path="/c/Windows/System32"
# ls "$system32_path" # debug print

dest_path="build/windows/runner/Release/"
cp "$system32_path/vcruntime140.dll" $dest_path
cp "$system32_path/vcruntime140_1.dll" $dest_path
cp "$system32_path/msvcp140.dll" $dest_path
