#!/usr/bin/env zsh

# See: https://github.com/koalaman/shellcheck/issues/809
# shellcheck shell=bash

set -euxo pipefail

# shellcheck disable=SC2168
local -A opthash
# See: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fzutil-Module
zparseopts -D -F -A opthash -- -dry-run -skip-test revision: p8-file-path: sentry-dsn:

if [[ -z "${opthash[(i)-revision]}" ]]; then
  echo "revision is required"
  exit
fi

if [ -z "${opthash[(i)-p8-file-path]}" ]; then
  echo "p8-file-path is required"
  exit
fi

if [ -z "${opthash[(i)-sentry-dsn]}" ]; then
  echo "sentry-dsn is required"
  exit
fi

git fetch --all --prune
git checkout "${opthash[-revision]}"

# shellcheck disable=SC1091
source ./scripts/setup_flutter.sh

if [[ -z "${opthash[(i)--skip-test]}" ]]; then
  flutter test --concurrency=1
  flutter test integration_test
fi

# See: https://flutter.dev/desktop#macos
flutter build macos --release --dart-define SENTRY_DSN="${opthash[-sentry-dsn]}"

cd macos

bundle --version
ruby --version

bundle config set --local deployment 'true'
bundle install
bundle exec fastlane list

ASC_KEY_CONTENT=$(base64 --input="${opthash[-p8-file-path]}")
export ASC_KEY_CONTENT

git diff --exit-code

if [[ -n "${opthash[(i)--dry-run]}" ]]; then
  echo "exit without running fastlane deploy_app_store, because dry-run option is specified"
  exit
fi

bundle exec fastlane deploy_app_store # require ENV variables. See: macos/fastlane/Fastfile