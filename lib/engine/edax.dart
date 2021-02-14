import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class Edax {
  const Edax();

  Future<LibEdax> initLibedax() async {
    await _initBookFilePref();
    await _initEvalFilePref();
    await _initDll();
    final libedax = LibEdax(await _libedaxPath);
    return libedax
      ..libedaxInitialize([
        '',
        '-eval-file',
        await evalPath,
        '-book-file',
        await bookPath,
        // 'n-tasks',
        // '12',
      ])
      ..edaxInit()
      ..edaxVersion();
  }

  /// after you call this, you have to call edaxBookLoad or libedaxInitialize with book-file option.
  Future<void> setBookPath(String path) async {
    final pref = await _pref;
    await pref.setString(bookFilePathPrefKey, path);
  }

  Future<void> setEvalPath(String path) async {
    final pref = await _pref;
    await pref.setString(evalFilePathPrefKey, path);
    // NOTE: require restart
  }

  Future<String> get bookPath async {
    final pref = await _pref;
    return pref.getString(bookFilePathPrefKey) ?? '';
  }

  Future<String> get evalPath async {
    final pref = await _pref;
    return pref.getString(evalFilePathPrefKey) ?? '';
  }

  Future<void> _initBookFilePref() async {
    if ((await bookPath).isNotEmpty) return;
    final docDir = await _docDir;
    await setBookPath('${docDir.path}/$defaultBookFileName');
  }

  Future<void> _initEvalFilePref() async {
    final docDir = await _docDir;
    final evalFilePath = await evalPath;
    // REF: https://github.com/flutter/flutter/issues/17160
    // REF: https://github.com/flutter/flutter/issues/28162
    if (evalFilePath.isEmpty) {
      final evalData = await _evalAssetData;
      final newEvalFilePath = '${docDir.path}/$defaultEvalFileName';
      File(newEvalFilePath).writeAsBytesSync(evalData.buffer.asUint8List());
      await setEvalPath(newEvalFilePath);
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

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async {
    final docDir = await getApplicationDocumentsDirectory();
    if (docDir == null) throw Exception('Documents Directory is not found');
    return docDir;
  }

  Future<SharedPreferences> get _pref async => SharedPreferences.getInstance();

  @visibleForTesting
  static const bookFilePathPrefKey = 'bookFilePath';

  @visibleForTesting
  static const evalFilePathPrefKey = 'evalFilePath';

  @visibleForTesting
  static const defaultEvalFileName = 'eval.dat';

  @visibleForTesting
  static const defaultBookFileName = 'book.dat';

  @visibleForTesting
  static String get defaultLibedaxName {
    if (Platform.isMacOS) return 'libedax.dylib';
    if (Platform.isWindows) return 'libedax-x64.dll';
    if (Platform.isLinux) return 'libedax.so';
    throw Exception('${Platform.operatingSystem} is not supported');
  }
}
