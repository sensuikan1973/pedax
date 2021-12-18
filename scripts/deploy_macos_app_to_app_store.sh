#!/bin/zsh
set -euxo pipefail

local -A opthash
# See: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fzutil-Module
zparseopts -D -F -A opthash -- -dry-run revision: p8-file-path:

if [[ -z "${opthash[(i)-revision]}" ]]; then
  echo "revision is required"
  exit
fi

if [ -z "${opthash[(i)-p8-file-path]}" ]; then
  echo "p8-file-path is required"
  exit
fi

git fetch --all --prune
git checkout ${opthash[-revision]}

source ./scripts/setup_flutter_channel.sh

flutter test --concurrency=1

flutter clean
flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart -d macos

# See: https://flutter.dev/desktop#macos
flutter clean
flutter build macos --release

cd macos
bundle config set --local deployment 'true'
bundle install

export ASC_KEY_CONTENT=$(cat ${opthash[-p8-file-path]} | base64)

git diff --exit-code

if [[ -n "${opthash[(i)--dry-run]}" ]]; then
  echo "exit withoud running fastlane deploy based on dry-run option."
  exit
fi

bundle exec fastlane deploy_app_store # require ENV variables
