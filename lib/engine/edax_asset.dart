import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'options/native/book_file_option.dart';
import 'options/native/engine_native_option.dart';
import 'options/native/eval_file_option.dart';
import 'options/native/level_option.dart';
import 'options/native/n_tasks_option.dart';

@doNotStore
@immutable
class EdaxAsset {
  const EdaxAsset();

  // See: https://github.com/flutter/flutter/issues/28162
  Future<void> setupDllAndData() async {
    await _setupDll();
    await _setupBookData();
    await _setupEvalData();
  }

  /// NOTE:
  /// If you pass BookFileOption(), be careful to the size.
  /// When book is large, initialization process becomes slow.
  /// In most cases, loading book should be processed on background
  Future<List<String>> buildInitLibEdaxParams({
    final List<EngineNativeOption<dynamic>> options = const [NTasksOption(), EvalFileOption(), LevelOption()],
  }) async {
    final result = [''];
    for (final option in options) {
      result
        ..add(option.nativeName)
        ..add((await option.val).toString());
    }
    return result;
  }

  Future<String> get libedaxPath async {
    if (Platform.isMacOS) {
      // See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
      return libedaxName;
    }
    if (Platform.isWindows || Platform.isLinux) return p.join((await _docDir).path, libedaxName);
    throw Exception('${Platform.operatingSystem} is not supported');
  }

  Future<void> _setupDll() async {
    if (Platform.isMacOS) {
      // See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
      return;
    }
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

  Future<void> _setupBookData() async {
    const option = BookFileOption();
    final bookFilePath = await option.val;
    if (!File(bookFilePath).existsSync()) {
      final bookData = await _bookAssetData;
      File(await option.appDefaultValue).writeAsBytesSync(bookData.buffer.asUint8List());
      await option.update(await option.appDefaultValue);
    }
  }

  Future<void> _setupEvalData() async {
    const option = EvalFileOption();
    final evalData = (await _evalAssetData).buffer.asUint8List();
    final evalDataSha256 = sha256.convert(evalData).toString();
    final pref = await _preferences;
    final currentEvalDataSha256 = pref.getString('libedax_eval_sha256');
    if (evalDataSha256 == currentEvalDataSha256) return;

    final evalFilePath = await option.val;
    if (!File(evalFilePath).existsSync()) {
      File(await option.appDefaultValue).writeAsBytesSync(evalData, flush: true);
      await option.update(await option.appDefaultValue);
    }

    await pref.setString('libedax_eval_sha256', evalDataSha256);
  }

  // REF: https://github.com/flutter/flutter/issues/17160
  // REF: https://github.com/flutter/flutter/issues/28162
  Future<ByteData> get _libedaxAssetData async => rootBundle.load('assets/libedax/dll/$libedaxName');
  Future<ByteData> get _evalAssetData async => rootBundle.load('assets/libedax/data/eval.dat');
  Future<ByteData> get _bookAssetData async => rootBundle.load('assets/libedax/data/book.dat');

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async => getApplicationDocumentsDirectory();

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();

  @visibleForTesting
  static String get libedaxName {
    if (Platform.isMacOS) return 'libedax.universal.dylib';
    if (Platform.isWindows) return 'libedax-x64.dll';
    if (Platform.isLinux) return 'libedax.so';
    throw Exception('${Platform.operatingSystem} is not supported');
  }
}
