#!/bin/bash
set -euxo pipefail

# See: https://docs.flutter.dev/platform-integration/desktop#additional-linux-requirements
sudo apt-get update -y
sudo apt-get install -y clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
