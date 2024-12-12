#!/bin/bash
set -euxo pipefail

# See: https://docs.flutter.dev/platform-integration/desktop#additional-linux-requirements
sudo apt-get update -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
sudo apt-get install -y clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# https://github.com/sensuikan1973/pedax/pull/2357#issuecomment-2535409742
sudo apt install -y libcurl4-openssl-dev
