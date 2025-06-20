#!/bin/bash
set -euxo pipefail

# https://docs.flutter.dev/get-started/install/linux/desktop#install-the-flutter-sdk
# https://docs.flutter.dev/install/archive#main-channel

FLUTTER_SDK_DIR="$HOME/.flutter_sdk"

git clone -b stable https://github.com/flutter/flutter.git "$FLUTTER_SDK_DIR"

echo export PATH="$PATH:$FLUTTER_SDK_DIR/flutter/bin" >> ~/.bashrc
source ~/.bashrc

flutter doctor
