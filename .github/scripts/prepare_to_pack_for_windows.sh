#!/bin/bash

# See: https://flutter.dev/desktop#windows
# See: https://github.com/sensuikan1973/pedax/pull/71#issuecomment-798849250
# See: https://github.com/sensuikan1973/pedax/pull/83#issuecomment-803240876
msvc_path="/c/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Redist/MSVC"
ls "$msvc_path"

target_vc_path="$msvc_path/14.28.29910/x64/Microsoft.VC142.CRT"
dest_path="build/windows/runner/Release/"
cp "$target_vc_path/vcruntime140.dll" $dest_path
cp "$target_vc_path/vcruntime140_1.dll" $dest_path
cp "$target_vc_path/msvcp140.dll" $dest_path
