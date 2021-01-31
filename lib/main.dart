// @dart = 2.11
// path_provider が null safety でないため
// See: https://dart.dev/null-safety/unsound-null-safety

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:libedax4dart/libedax4dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

Future<void> main() async {
  final docDir = await getApplicationDocumentsDirectory();

  final pref = await SharedPreferences.getInstance();
  if (pref.getString('bookFilePath') == null) {
    await pref.setString('bookFilePath', '${docDir.path}/book.dat'); // とりあえず
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

  LibEdax(pref.getString('libedaxPath'))
    ..libedaxInitialize(
      ['', '-eval-file', pref.getString('evalFilePath'), '-book-file', pref.getString('bookFilePath')],
    )
    ..edaxVersion();

  runApp(const MyApp());
}
