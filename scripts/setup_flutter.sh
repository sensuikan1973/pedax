#!/bin/bash

set -euxo pipefail

flutter clean

# TODO: remove this workaround, if https://github.com/sensuikan1973/pedax/issues/1221#issuecomment-1510596373 is resolved.
flutter_revision=${1:-""}
if [ -n "$flutter_revision" ]; then
  flutter_repository_path=$(flutter doctor --verbose | grep "Flutter version" | awk -F ' at ' '{print $2}')
  cd "$flutter_repository_path"
  git remote update --prune
  git checkout "$flutter_revision"
  cd -
else
  flutter channel stable
  flutter upgrade
fi

flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# disable platforms that I won’t develop for.
# See: https://docs.flutter.dev/desktop#set-up
flutter config --no-enable-ios
flutter config --no-enable-android
flutter config --no-enable-web # See: https://github.com/sensuikan1973/pedax/issues/481

# useful flutter desktop sample
# - https://github.com/flutter/samples/tree/master/desktop_photo_search
# - https://github.com/flutter/gallery
# - https://github.com/authpass/authpass
# - https://github.com/MixinNetwork/flutter-app
#   - useful plugins: https://github.com/MixinNetwork/flutter-plugins
