# NOTE: 現状は全ての Platform の dynamic library を asset に配置してる。
# TODO: Platform 単位でビルドに含めるかを分ける。

mkdir -p assets/libedax
dll_dst=assets/libedax/dll
data_dst=assets/libedax/data
mkdir -p $dll_dst
mkdir -p $data_dst

tmp_dst=libedax_assets_tmp
mkdir -p $tmp_dst

tag=libedax-assets_2
asset_url_prefix=https://github.com/sensuikan1973/libedax4dart/releases/download/$tag

function unpack_dyamic_library() {
  platform=$1
  asset_url=$2
  lib_name=$3
  curl -L $asset_url -o $tmp_dst/${platform}_asset.zip && unzip $tmp_dst/${platform}_asset.zip -d $tmp_dst/${platform}
  mv $tmp_dst/${platform}/libedax_output/bin/${lib_name} $dll_dst
}

# Mac dynamic library
unpack_dyamic_library mac $asset_url_prefix/libedax_macOS.zip libedax.dylib
# Linux dynamic library
unpack_dyamic_library linux $asset_url_prefix/libedax_Linux.zip libedax.so
# Windows dynamic library
unpack_dyamic_library windows $asset_url_prefix/libedax_Windows.zip libedax-x64.dll

# data
mv $tmp_dst/mac/libedax_output/data/eval.dat $data_dst

rm -rf $tmp_dst
