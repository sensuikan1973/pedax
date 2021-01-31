// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// TODO: remove this Experiment function
Future<String> tryToCallEdax() async {
  final docDir = await getApplicationDocumentsDirectory();

  final pref = await SharedPreferences.getInstance();
  if (pref.getString('bookFilePath') == null) {
    await pref.setString('bookFilePath', '${docDir.path}/book.dat'); // for now
  }
  if (pref.getString('evalFilePath') == null) {
    final evalData = await rootBundle.load('assets/libedax/data/eval.dat');
    final evalFilePath = '${docDir.path}/eval.dat';
    File(evalFilePath).writeAsBytesSync(evalData.buffer.asUint8List());
    await pref.setString('evalFilePath', evalFilePath);
  }
  if (pref.getString('libedaxPath') == null) {
    var libedaxName = '';
    if (Platform.isMacOS) libedaxName = 'libedax.dylib';
    if (Platform.isWindows) libedaxName = 'libedax-x64.dll';
    if (Platform.isLinux) libedaxName = 'libedax.so';
    final libedaxData = await rootBundle.load('assets/libedax/dll/$libedaxName');
    final libedaxPath = '${docDir.path}/$libedaxName';
    File(libedaxPath).writeAsBytesSync(libedaxData.buffer.asUint8List());
    await pref.setString('libedaxPath', libedaxPath);
  }

  final edax = LibEdax(pref.getString('libedaxPath'))
    ..libedaxInitialize(
      ['', '-eval-file', pref.getString('evalFilePath'), '-book-file', pref.getString('bookFilePath')],
    )
    ..edaxInit()
    ..edaxVersion();
  return edax.edaxGetBoard().prettyString(TurnColor.black);
}
