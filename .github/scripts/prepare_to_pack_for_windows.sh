# See: https://flutter.dev/desktop#windows
# See: https://github.com/sensuikan1973/pedax/pull/71#issuecomment-798849250
target_dll_path="/c/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Redist/MSVC/14.28.29325/x64/Microsoft.VC142.CRT"
cp "$target_dll_path/vcruntime140.dll" build/windows/runner/Release/
cp "$target_dll_path/vcruntime140_1.dll" build/windows/runner/Release/
cp "$target_dll_path/msvcp140.dll" build/windows/runner/Release/
