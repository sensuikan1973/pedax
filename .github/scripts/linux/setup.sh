#!/bin/bash
set -euxo pipefail

# See: https://docs.flutter.dev/desktop#additional-linux-requirements
sudo apt-get update -y
sudo snap install flutter --classic

# See: https://flutter.dev/desktop#set-up
flutter config --enable-linux-desktop
