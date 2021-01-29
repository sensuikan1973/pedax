// @dart = 2.11
// path_provider が null safety でないため
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter/foundation.dart';
// ignore: unused_import
import 'package:path_provider/path_provider.dart'; // 使う

@immutable
class Edax {
  Edax() {
    // TODO: 実装
    // loadPreferences で book, eval, dll の path を入手し、edax を起動する
    // preferences が無い/定義が無い場合は、Asset Bundle から「book, eval, dll, 設定ファイル(yaml かな? 扱いやすければ何でもok)」をコピってきて、そこを参照するようにする
  }

  void setBookPath() {
    // TODO: 実装
    // updatePreferences()
    // 後続の処理で book load が必要
    // libedax4dart にそもそも book_load の binding をまだ実装してないので、そっちの実装追加も必要
    // まあ優先度低いので、アプリ自体の再起動が必要、というメッセージを明示しておく でもok。
  }

  void setEvalPath() {
    // TODO: 実装
    // updatePreferences()
    // アプリ自体の再起動が必要、というメッセージを明示しておく
  }

  void setDllPath() {
    // TODO: 実装
    // updatePreferences()
    // アプリ自体の再起動が必要、というメッセージを明示しておく
  }

  // ignore: prefer_expression_function_bodies
  String loadPreferences() {
    // TODO: 実装
    // path_provider で platform に応じた領域を参照する
    return '';
  }

  void updatePreferences() {
    // TODO: 実装
    // path_provider で platform に応じた領域へ書き込む
  }
}
