#!/bin/bash
set -euxo pipefail

# See: https://docs.flutter.dev/platform-integration/desktop#additional-macos-requirements

# CocoaPods
gem update --system # use latest rubygems
gem update cocoapods # use latest cocoapods
pod repo update
