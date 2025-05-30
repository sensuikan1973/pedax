#!/bin/bash

set -euxo pipefail

flutter channel stable

flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers
flutter config --enable-swift-package-manager

# disable platforms that I won’t develop for.
# See: https://docs.flutter.dev/desktop#set-up
flutter config --no-enable-ios
flutter config --no-enable-android
flutter config --no-enable-web # See: https://github.com/sensuikan1973/pedax/issues/481

flutter clean
flutter upgrade

# useful flutter desktop sample
# - https://github.com/flutter/samples/tree/master/desktop_photo_search
# - https://github.com/authpass/authpass
# - https://github.com/MixinNetwork/flutter-app
#   - useful plugins: https://github.com/MixinNetwork/flutter-plugins
