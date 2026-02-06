#!/bin/bash
set -euxo pipefail

echo "See: https://docs.flutter.dev/platform-integration/windows/building#distributing-windows-apps"

dart run msix:create

# For developers which want to run `.exe` directly, I repack ***.dll.
# See: https://docs.flutter.dev/platform-integration/windows/building#building-your-own-zip-file-for-windows
# REF: https://github.com/sensuikan1973/pedax/pull/71#issuecomment-798849250
# REF: https://github.com/sensuikan1973/pedax/pull/83#issuecomment-803240876
# REF: https://github.com/authpass/authpass/blob/a582bd0f9fb74e2b96a27cb59d73118a08374b73/authpass/_tools/release.sh#L177
system32_path="/c/Windows/System32"
# ls "$system32_path" # debug print

dest_path="build/windows/x64/runner/Release/" # https://docs.flutter.dev/release/breaking-changes/windows-build-architecture

cp "$system32_path/vcruntime140.dll" $dest_path
cp "$system32_path/vcruntime140_1.dll" $dest_path
cp "$system32_path/msvcp140.dll" $dest_path
