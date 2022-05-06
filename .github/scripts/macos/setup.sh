#!/bin/bash
set -euxo pipefail

# See: https://docs.flutter.dev/desktop#additional-macos-requirements

# See: https://docs.flutter.dev/desktop#set-up
flutter config --enable-macos-desktop

cd macos || exit
pod install
