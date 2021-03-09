# See: https://flutter.dev/desktop#macos

flutter channel dev
flutter upgrade

flutter test
flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart -d macos

flutter clean
flutter build macos
open macos/Runner.xcworkspace

# See: https://help.apple.com/xcode/mac/current/#/devac02c5ab8

# Archive
# Validate
# Upload
# Publish
