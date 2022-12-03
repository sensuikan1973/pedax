#!/bin/bash
set -euxo pipefail

echo "See: https://docs.flutter.dev/development/platform-integration/linux/building#preparing-linux-apps-for-distribution"

sudo apt-get install libgtk-3-0 libblkid1 liblzma5
