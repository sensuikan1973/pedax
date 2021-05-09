import 'dart:io';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

import 'options/book_file_option.dart';
import 'options/edax_option.dart';
import 'options/eval_file_option.dart';
import 'options/level_option.dart';
import 'options/n_tasks_option.dart';

@doNotStore
@immutable
class EdaxAsset {
  const EdaxAsset();

  Future<void> setupDllAndData() async {
    await _setupBookData();
    await _setupEvalData();
  }

  Future<List<String>> buildInitLibEdaxParams() async {
    const options = <EdaxOption>[
      NTasksOption(),
      EvalFileOption(),
      // BookFileOption(), // NOTE: when book is large, initialize is very slow. So, loading book should be processed on background.
      LevelOption(),
    ];
    final result = [''];
    for (final option in options) {
      result..add(option.nativeName)..add((await option.val).toString());
    }
    return result;
  }

  String get libedaxPath => libedaxName;

  // ignore: unused_element, prefer_expression_function_bodies
  void _setupDll() {
    return; // do nothing. I have already bundled directly on each platform.
    // For MacOS, See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
    // For Windows, copy windows/libedax-x64.dll to build directory.
    // For Linux, copy linux/libedax.so to build directory.
  }

  Future<void> _setupBookData() async {
    const option = BookFileOption();
    final bookFilePath = await option.val;
    // REF: https://github.com/flutter/flutter/issues/17160
    // REF: https://github.com/flutter/flutter/issues/28162
    if (bookFilePath.isEmpty) {
      final bookData = await _bookAssetData;
      File(await option.appDefaultValue).writeAsBytesSync(bookData.buffer.asUint8List());
      await option.update(await option.appDefaultValue);
    } else if (!File(bookFilePath).existsSync()) {
      final bookData = await _bookAssetData;
      File(bookFilePath).writeAsBytesSync(bookData.buffer.asUint8List(), flush: true);
    }
  }

  Future<void> _setupEvalData() async {
    const option = EvalFileOption();
    final evalFilePath = await option.val;
    // REF: https://github.com/flutter/flutter/issues/17160
    // REF: https://github.com/flutter/flutter/issues/28162
    if (evalFilePath.isEmpty) {
      final evalData = await _evalAssetData;
      File(await option.appDefaultValue).writeAsBytesSync(evalData.buffer.asUint8List());
      await option.update(await option.appDefaultValue);
    } else if (!File(evalFilePath).existsSync()) {
      final evalData = await _evalAssetData;
      File(evalFilePath).writeAsBytesSync(evalData.buffer.asUint8List(), flush: true);
    }
  }

  Future<ByteData> get _evalAssetData async => rootBundle.load('assets/libedax/data/eval.dat');
  Future<ByteData> get _bookAssetData async => rootBundle.load('assets/libedax/data/book.dat');

  @visibleForTesting
  static String get libedaxName {
    if (Platform.isMacOS) return 'libedax.dylib';
    if (Platform.isWindows) return 'libedax-x64.dll';
    if (Platform.isLinux) return 'libedax.so';
    throw Exception('${Platform.operatingSystem} is not supported');
  }
}
