#!/bin/bash

set -euxo pipefail

# TODO: if flutter stable channel resolve https://github.com/sensuikan1973/pedax/issues/457, change channel to stable.
flutter channel beta

flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# disable platforms that I won’t develop for.
# See: https://docs.flutter.dev/desktop#set-up
flutter config --no-enable-ios
flutter config --no-enable-android
flutter config --no-enable-web # See: https://github.com/sensuikan1973/pedax/issues/481

flutter clean
flutter upgrade
