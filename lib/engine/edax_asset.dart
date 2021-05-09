import 'dart:io';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
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
    await _setupDll();
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

  Future<String> get libedaxPath async {
    // See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
    if (Platform.isMacOS) return libedaxName;
    final docDir = await _docDir;
    if (Platform.isWindows) return p.join(docDir.path, libedaxName);
    if (Platform.isLinux) return p.join(docDir.path, libedaxName);
    throw Exception('${Platform.operatingSystem} is not supported');
  }

  Future<void> _setupDll() async {
    // See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
    if (Platform.isMacOS) return;
    if (Platform.isWindows || Platform.isLinux) {
      final libedaxData = (await _libedaxAssetData).buffer.asUint8List();
      final libedaxDataSha256 = sha256.convert(libedaxData).toString();
      final pref = await _preferences;
      final currentLibedaxDataSha256 = pref.getString('libedax_dylib_sha256');
      if (libedaxDataSha256 == currentLibedaxDataSha256) return;

      File(await libedaxPath).writeAsBytesSync(libedaxData, flush: true);
      await pref.setString('libedax_dylib_sha256', libedaxDataSha256);
    }
  }

  // REF: https://github.com/flutter/flutter/issues/28162
  Future<void> _setupBookData() async {
    const option = BookFileOption();
    final bookFilePath = await option.val;
    final bookData = await _bookAssetData;
    if (bookFilePath.isEmpty) {
      File(await option.appDefaultValue).writeAsBytesSync(bookData.buffer.asUint8List());
      await option.update(await option.appDefaultValue);
    } else if (!File(bookFilePath).existsSync()) {
      File(bookFilePath).writeAsBytesSync(bookData.buffer.asUint8List(), flush: true);
    }
  }

  // REF: https://github.com/flutter/flutter/issues/28162
  Future<void> _setupEvalData() async {
    const option = EvalFileOption();
    final evalFilePath = await option.val;
    final evalData = await _evalAssetData;
    if (evalFilePath.isEmpty) {
      File(await option.appDefaultValue).writeAsBytesSync(evalData.buffer.asUint8List());
      await option.update(await option.appDefaultValue);
    } else if (!File(evalFilePath).existsSync()) {
      File(evalFilePath).writeAsBytesSync(evalData.buffer.asUint8List(), flush: true);
    }
  }

  Future<ByteData> get _libedaxAssetData async => rootBundle.load('assets/libedax/dll/$libedaxName');

  // REF: https://github.com/flutter/flutter/issues/17160
  Future<ByteData> get _evalAssetData async => rootBundle.load('assets/libedax/data/eval.dat');
  // REF: https://github.com/flutter/flutter/issues/17160
  Future<ByteData> get _bookAssetData async => rootBundle.load('assets/libedax/data/book.dat');

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async => getApplicationDocumentsDirectory();

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();

  @visibleForTesting
  static String get libedaxName {
    if (Platform.isMacOS) return 'libedax.dylib';
    if (Platform.isWindows) return 'libedax-x64.dll';
    if (Platform.isLinux) return 'libedax.so';
    throw Exception('${Platform.operatingSystem} is not supported');
  }
}
