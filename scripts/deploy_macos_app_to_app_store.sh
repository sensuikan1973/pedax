# See: https://flutter.dev/desktop#macos

set -eux

tag=$1
if [ -z "$tag" ]
then
  echo "tag is required"
  exit
fi

asc_key_p8_file_path=$2
if [ -z "$asc_key_p8_file_path" ]
then
  echo "asc_key_p8_file_path is required"
  exit
fi

git checkout $tag

flutter channel beta
flutter upgrade

flutter clean

flutter test

flutter clean
flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart -d macos

flutter clean
flutter build macos --release

git diff --exit-code

cd macos
bundle install
export ASC_KEY_CONTENT=$(cat $asc_key_p8_file_path | base64)
bundle exec fastlane deploy_app_store # require ENV variables
