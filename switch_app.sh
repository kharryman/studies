#!/bin/bash
old_app=$1
new_app=$2
echo "old_app: $old_app, new_app: $new_app"
echo "Creating new lib/cheatlist_data..."
rm -rf ./lib/cheatlist_data
mkdir ./lib/cheatlist_data
echo "COPYING TO lib/cheatlist_data..."
cp -r ./env_vars/"$new_app"_data/data ./lib/cheatlist_data/data
cp ./env_vars/"$new_app"_data/data.js ./lib/cheatlist_data/data.js
cp ./env_vars/"$new_app"_data/info.js ./lib/cheatlist_data/info.js
echo "COPYING TO \assets\images..."
rm -r ./assets/images
cp -r ./env_vars/"$new_app"_data/images ./assets/images
echo "COPYING ./env_vars/"$new_app"_data/"$new_app"_pubspec.yaml TO ./pubspec.yaml..."
cp ./env_vars/"$new_app"_data/"$new_app"_pubspec.yaml ./pubspec.yaml
echo "COPYING ./env_vars/"$new_app"_data/"$new_app"_AndroidManifest.xml TO ./android/app/src/main/AndroidManifest.xml..."
#cp ./env_vars/"$new_app"_data/"$new_app"_AndroidManifest.xml ./android/app/src/main/AndroidManifest.xml
flutter pub run change_app_package_name:main com.lfq.studies-"$new_app
node rename_package_files_ios.js $old_app $new_app
echo "COPYING APP ICONS..."
#cp -r ./env_vars/"$new_app"_data/icons/android ./android/app/src/main/res
cp -r ./env_vars/"$new_app"_data/icons/ios/Assets.xcassets ./ios/Runner/Assets.xcassets

flutter pub run flutter_native_splash:create
flutter clean
flutter pub get