#!/usr/bin/env zsh

# See: https://github.com/koalaman/shellcheck/issues/809
# shellcheck shell=bash

set -uxo pipefail

mkdir -p assets/libedax
data_dst=assets/libedax/data
mkdir -p $data_dst

tmp_dst=libedax_assets_tmp
mkdir -p $tmp_dst

tag=$(grep 'libedax4dart:' pubspec.yaml | awk -F '^' '{print $2}')
asset_url_prefix=https://github.com/sensuikan1973/libedax4dart/releases/download/$tag
# See: https://github.com/sensuikan1973/libedax4dart/releases/latest

function unpack_dyamic_library() {
  platform=$1
  asset_url=$2
  lib_name=$3
  dll_dst=$4
  curl -L "$asset_url" -o "$tmp_dst/${platform}_asset.zip"
  unzip "$tmp_dst/${platform}_asset.zip" -d "$tmp_dst/${platform}"
  mv "$tmp_dst/${platform}/libedax_output/bin/${lib_name}" "$dll_dst"
}

# Linux dynamic library
unpack_dyamic_library linux "$asset_url_prefix/libedax_Linux.zip" libedax.so assets/libedax/dll
# Windows dynamic library
unpack_dyamic_library windows "$asset_url_prefix/libedax_Windows.zip" libedax-x64.dll assets/libedax/dll
# MacOS dynamic library
# See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
unpack_dyamic_library macos "$asset_url_prefix/libedax_macOS.zip" libedax.dylib macos

# data
mv "$tmp_dst/linux/libedax_output/data/eval.dat" "$data_dst"

rm -rf "$tmp_dst"
