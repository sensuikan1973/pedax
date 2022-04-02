#!/bin/bash

# See: https://github.com/koalaman/shellcheck/issues/809
# shellcheck shell=bash

set -euxo pipefail

flutter channel "$(cat .flutter_channel)"

flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

flutter upgrade
flutter clean
