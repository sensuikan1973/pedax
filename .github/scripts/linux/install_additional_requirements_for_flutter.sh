#!/bin/bash
set -euxo pipefail

# See: https://docs.flutter.dev/desktop#additional-linux-requirements
sudo apt-get update -y
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
