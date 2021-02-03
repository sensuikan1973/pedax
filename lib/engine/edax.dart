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
  const Edax();

  Future<void> setBookPath(String path) async {
    final pref = await _pref;
    await pref.setString(bookFilePathPrefKey, path);
    // NOTE: require restart (OR call edax_book_load)
  }

  Future<void> setEvalPath(String path) async {
    final pref = await _pref;
    await pref.setString(evalFilePathPrefKey, path);
    // NOTE: require restart
  }

  // NOTE: If you need, implement.
  // Future<void> setDllPath(String path) async {
  //   final pref = await _pref;
  //   await pref.setString(libedaxPathPrefKey, path);
  //   // require restart
  // }

  Future<String> get bookPath async {
    final pref = await _pref;
    return pref.getString(bookFilePathPrefKey);
  }

  Future<String> get evalPath async {
    final pref = await _pref;
    return pref.getString(evalFilePathPrefKey);
  }

  // NOTE: If you need, implement.
  // Future<String> get dllPath async {
  //   final pref = await _pref;
  //   return pref.getString(libedaxPathPrefKey);
  // }

  /// TODO: remove this Experiment function
  /// ref: https://github.com/flutter/flutter/issues/17160
  Future<String> tryToCallEdax() async {
    final docDir = await _docDir;
    final pref = await _pref;

    if (pref.getString(bookFilePathPrefKey) == null) {
      await pref.setString(bookFilePathPrefKey, '${docDir.path}/$defaultBookFileName');
    }
    if (pref.getString(evalFilePathPrefKey) == null) {
      final evalData = await _evalAssetData;
      final evalFilePath = '${docDir.path}/$defaultEvalFileName';
      File(evalFilePath).writeAsBytesSync(evalData.buffer.asUint8List());
      await pref.setString(evalFilePathPrefKey, evalFilePath);
    } else {
      final evalFilePath = pref.getString(evalFilePathPrefKey);
      if (!File(evalFilePath).existsSync()) {
        final evalData = await _evalAssetData;
        File(evalFilePath).writeAsBytesSync(evalData.buffer.asUint8List());
      }
    }

    // FIXME: remove this.
    if (Platform.isWindows || Platform.isLinux) {
      final libedaxData = await _libedaxAssetData;
      File(await _libedaxPath).writeAsBytesSync(libedaxData.buffer.asUint8List());
    }

    final edax = LibEdax(await _libedaxPath)
      ..libedaxInitialize([
        '',
        '-eval-file',
        pref.getString(evalFilePathPrefKey),
        '-book-file',
        pref.getString(bookFilePathPrefKey),
      ])
      ..edaxInit()
      ..edaxVersion();
    return edax.edaxGetBoard().prettyString(TurnColor.black);
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

  // e.g. Mac: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async => getApplicationDocumentsDirectory();

  Future<SharedPreferences> get _pref async => SharedPreferences.getInstance();

  @visibleForTesting
  static const bookFilePathPrefKey = 'bookFilePath';

  @visibleForTesting
  static const evalFilePathPrefKey = 'evalFilePath';

  // NOTE: If you need, implement.
  // @visibleForTesting
  // static const libedaxPathPrefKey = 'libedaxPath';

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
