#!/bin/bash
set -euxo pipefail

# See: https://flutter.dev/desktop#additional-linux-requirements
sudo apt-get update -y
sudo apt-get install -y libgtk-3-dev libx11-dev pkg-config cmake ninja-build libblkid-dev liblzma-dev

# See: https://flutter.dev/desktop#set-up
flutter config --enable-linux-desktop
