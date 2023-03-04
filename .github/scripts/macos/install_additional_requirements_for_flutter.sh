#!/bin/bash
set -euxo pipefail

# CocoaPods
gem update cocoapods # use latest version
pod repo update

# See: https://docs.flutter.dev/desktop#additional-macos-requirements
