#!/usr/bin/env zsh

# https://appstoreconnect.apple.com/apps

# See: https://github.com/koalaman/shellcheck/issues/809
# shellcheck shell=bash

set -euxo pipefail

# shellcheck disable=SC2168
local -A opthash
# See: https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fzutil-Module
zparseopts -D -F -A opthash -- -dry-run revision:

if [[ -z "${opthash[(i)-revision]}" ]]; then
  echo "revision is required"
  exit
fi

git fetch --all --prune
git checkout "${opthash[-revision]}"

# shellcheck disable=SC1091
source ./scripts/setup_flutter.sh

# See: https://flutter.dev/desktop#macos
flutter build macos --release --dart-define SENTRY_DSN="$SENTRY_DSN"

cd macos
ruby --version
bundle --version

bundle config set --local deployment 'true'
bundle install
bundle exec fastlane list

git diff --exit-code

# require ENV variables. See: macos/fastlane/Fastfile.
if [[ -n "${opthash[(i)--dry-run]}" ]]; then
  bundle exec fastlane deploy_app_store verify_only:true --verbose
else
  bundle exec fastlane deploy_app_store --verbose
fi
