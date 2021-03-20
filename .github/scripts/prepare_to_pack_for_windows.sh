#!/bin/bash

# See: https://flutter.dev/desktop#windows
# See: https://github.com/sensuikan1973/pedax/pull/71#issuecomment-798849250
msvc_path="/c/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Redist/MSVC"
ls $msvc_path

target_vc_path="$msvc_path/14.28.29325/x64/Microsoft.VC142.CRT"
cp "$target_vc_path/vcruntime140.dll" build/windows/runner/Release/
cp "$target_vc_path/vcruntime140_1.dll" build/windows/runner/Release/
cp "$target_vc_path/msvcp140.dll" build/windows/runner/Release/
