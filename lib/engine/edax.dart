import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Edax {
  Edax();

  late final LibEdax lib;

  Future<bool> initLibedax() async {
    await _initBookFilePref();
    await _initEvalFilePref();
    await _initDll();
    lib = LibEdax(await _libedaxPath);
    lib
      ..libedaxInitialize([
        '',
        '-eval-file',
        await evalPath,
        '-book-file',
        await bookPath,
        'n-tasks',
        (await nTasks).toString(),
      ])
      ..edaxInit()
      ..edaxVersion();
    return true;
  }

  /// after you call this, you have to call edaxBookLoad or libedaxInitialize with book-file option.
  Future<void> setBookPath(String path) async {
    final pref = await _pref;
    if (path.isEmpty) {
      await pref.setString(bookFilePathPrefKey, await _defaultBookFilePath);
    } else {
      await pref.setString(bookFilePathPrefKey, path);
    }
  }

  // after you call this, you have to recall libedaxInitialize with eval-file option.
  // for now, libedax4dart doesn't have eval_load command.
  Future<void> setEvalPath(String path) async {
    final pref = await _pref;
    if (path.isEmpty) {
      await pref.setString(evalFilePathPrefKey, await _defaultEvalFilePath);
    } else {
      await pref.setString(evalFilePathPrefKey, path);
    }
  }

  Future<void> setNTasks(int n) async {
    final pref = await _pref;
    if (n < 1 || Platform.numberOfProcessors < n) {
      await pref.setInt(nTasksPrefKey, _defaultNTasks);
    } else {
      await pref.setInt(nTasksPrefKey, n);
    }
  }

  Future<String> get bookPath async {
    final pref = await _pref;
    return pref.getString(bookFilePathPrefKey) ?? '';
  }

  Future<String> get evalPath async {
    final pref = await _pref;
    return pref.getString(evalFilePathPrefKey) ?? '';
  }

  Future<int> get nTasks async {
    final pref = await _pref;
    return pref.getInt(nTasksPrefKey) ?? _defaultNTasks;
  }

  Future<void> _initBookFilePref() async {
    final bookFilePath = await bookPath;
    // REF: https://github.com/flutter/flutter/issues/17160
    // REF: https://github.com/flutter/flutter/issues/28162
    if (bookFilePath.isEmpty) {
      final bookData = await _bookAssetData;
      File(await _defaultBookFilePath).writeAsBytesSync(bookData.buffer.asUint8List());
      await setBookPath(await _defaultBookFilePath);
    } else if (!File(bookFilePath).existsSync()) {
      final bookData = await _bookAssetData;
      File(bookFilePath).writeAsBytesSync(bookData.buffer.asUint8List());
    }
  }

  Future<void> _initEvalFilePref() async {
    final evalFilePath = await evalPath;
    // REF: https://github.com/flutter/flutter/issues/17160
    // REF: https://github.com/flutter/flutter/issues/28162
    if (evalFilePath.isEmpty) {
      final evalData = await _evalAssetData;
      File(await _defaultEvalFilePath).writeAsBytesSync(evalData.buffer.asUint8List());
      await setEvalPath(await _defaultEvalFilePath);
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

  Future<String> get _defaultEvalFilePath async => '${(await _docDir).path}/$defaultEvalFileName';
  Future<String> get _defaultBookFilePath async => '${(await _docDir).path}/$defaultBookFileName';
  int get _defaultNTasks => (Platform.numberOfProcessors / 2).floor();

  Future<ByteData> get _libedaxAssetData async => rootBundle.load('assets/libedax/dll/$defaultLibedaxName');
  Future<ByteData> get _evalAssetData async => rootBundle.load('assets/libedax/data/eval.dat');
  Future<ByteData> get _bookAssetData async => rootBundle.load('assets/libedax/data/book.dat');

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
  static const nTasksPrefKey = 'nTasks';

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
