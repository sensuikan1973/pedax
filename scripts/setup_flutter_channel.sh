set -euxo pipefail

flutter channel $(cat .flutter_channel)
flutter upgrade
flutter clean
