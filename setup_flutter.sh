#!/bin/bash

# Flutter SDK のバージョン (必要に応じて変更してください)
FLUTTER_VERSION="3.19.0" # 例: 最新の安定版などを指定
# Flutter SDK を展開するディレクトリ (ユーザーのホームディレクトリ配下の .flutter_sdk とします)
FLUTTER_SDK_DIR="$HOME/.flutter_sdk"
FLUTTER_INSTALL_DIR="$FLUTTER_SDK_DIR/flutter"

echo "Flutter SDK のセットアップを開始します..."

# 既に Flutter SDK が存在するか確認
if [ -d "$FLUTTER_INSTALL_DIR" ]; then
  echo "Flutter SDK は既に $FLUTTER_INSTALL_DIR に存在します。"
  echo "既存のSDKを使用します。"
else
  echo "Flutter SDK を $FLUTTER_SDK_DIR にダウンロードして展開します..."
  # ディレクトリが存在しない場合は作成
  mkdir -p "$FLUTTER_SDK_DIR"
  cd "$FLUTTER_SDK_DIR"

  # Flutter SDK をダウンロード (Linux x64 の場合)
  # アーキテクチャが異なる場合は、適切な URL に変更してください
  # 最新版は公式サイトで確認してください: https://flutter.dev/docs/get-started/install/linux#install-flutter-manually
  FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  wget "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$FLUTTER_ARCHIVE"

  if [ $? -ne 0 ]; then
    echo "Flutter SDK のダウンロードに失敗しました。"
    exit 1
  fi

  # ダウンロードしたアーカイブを展開
  tar xf "$FLUTTER_ARCHIVE"

  if [ $? -ne 0 ]; then
    echo "Flutter SDK の展開に失敗しました。"
    exit 1
  fi

  # 不要になったアーカイブファイルを削除
  rm "$FLUTTER_ARCHIVE"

  echo "Flutter SDK の展開が完了しました。"
fi

# PATH に Flutter SDK の bin ディレクトリを追加
# この設定は現在のセッションでのみ有効です。
# 永続的に設定するには、~/.bashrc や ~/.zshrc などに追記してください。
export PATH="$PATH:$FLUTTER_INSTALL_DIR/bin"

echo "PATH に Flutter SDK を追加しました: $PATH"

# Flutter Doctor を実行してセットアップ状況を確認
echo "Flutter Doctor を実行します..."
flutter doctor

echo ""
echo "Flutter SDK のセットアップが完了しました。"
echo "永続的にPATHを設定するには、お使いのシェルの設定ファイル (例: ~/.bashrc, ~/.zshrc) に以下を追記してください:"
echo "  export PATH="\$PATH:$FLUTTER_INSTALL_DIR/bin""
echo "設定変更後は、新しいターミナルを開くか、'source ~/.bashrc' (または該当ファイル) を実行してください。"
