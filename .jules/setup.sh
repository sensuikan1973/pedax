#!/bin/bash
set -euxo pipefail

# https://docs.flutter.dev/get-started/install/linux/desktop#install-the-flutter-sdk
# https://docs.flutter.dev/install/archive#main-channel

git clone https://github.com/flutter/flutter
sudo mv flutter /usr/local/
export PATH=$PATH:/usr/local/flutter/bin
export PATH="$PATH:/usr/local/flutter/bin" >> ~/.bash_profile

flutter --version

./scripts/setup_flutter.sh
