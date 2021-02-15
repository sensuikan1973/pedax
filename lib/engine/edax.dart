import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:path_provider/path_provider.dart';

import 'options/book_file_option.dart';
import 'options/edax_option.dart';
import 'options/eval_file_option.dart';
import 'options/n_tasks_option.dart';

class Edax {
  Edax();

  late final LibEdax lib;

  Future<bool> initLibedax() async {
    await _initBookFilePref();
    await _initEvalFilePref();
    await _initDll();
    lib = LibEdax(await _libedaxPath);
    lib
      ..libedaxInitialize(await _initParams)
      ..edaxInit()
      ..edaxVersion();
    return true;
  }

  Future<List<String>> get _initParams async {
    const options = <EdaxOption>[NTasksOption(), EvalFileOption(), BookFileOption()];
    final result = [''];
    for (final option in options) {
      result..add(option.nativeName)..add((await option.val).toString());
    }
    return result;
  }

  Future<void> _initBookFilePref() async {
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
      File(bookFilePath).writeAsBytesSync(bookData.buffer.asUint8List());
    }
  }

  Future<void> _initEvalFilePref() async {
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
      File(evalFilePath).writeAsBytesSync(evalData.buffer.asUint8List());
    }
  }

  Future<void> _initDll() async {
    // See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
    if (Platform.isMacOS) return;
    // TODO: consider to fix this copy handling
    if (Platform.isWindows || Platform.isLinux) {
      final libedaxData = await _libedaxAssetData;
      File(await _libedaxPath).writeAsBytesSync(libedaxData.buffer.asUint8List());
    }
  }

  Future<String> get _libedaxPath async {
    // See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
    if (Platform.isMacOS) return defaultLibedaxName;
    // FIXME: temporary implement.
    final docDir = await _docDir;
    if (Platform.isWindows) return '${docDir.path}/$defaultLibedaxName';
    if (Platform.isLinux) return '${docDir.path}/$defaultLibedaxName';
    throw Exception('${Platform.operatingSystem} is not supported');
  }

  Future<ByteData> get _libedaxAssetData async => rootBundle.load('assets/libedax/dll/$defaultLibedaxName');
  Future<ByteData> get _evalAssetData async => rootBundle.load('assets/libedax/data/eval.dat');
  Future<ByteData> get _bookAssetData async => rootBundle.load('assets/libedax/data/book.dat');

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async {
    final docDir = await getApplicationDocumentsDirectory();
    if (docDir == null) throw Exception('Documents Directory is not found');
    return docDir;
  }

  @visibleForTesting
  static String get defaultLibedaxName {
    if (Platform.isMacOS) return 'libedax.dylib';
    if (Platform.isWindows) return 'libedax-x64.dll';
    if (Platform.isLinux) return 'libedax.so';
    throw Exception('${Platform.operatingSystem} is not supported');
  }
}
