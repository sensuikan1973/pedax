import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pedax/engine/edax_asset.dart';
import 'package:pedax/engine/options/book_file_option.dart';
import 'package:pedax/engine/options/eval_file_option.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> prepareLibedaxAssets({bool setPref = true}) async {
  // See: https://flutter.dev/docs/cookbook/persistence/reading-writing-files#testing
  final dir = await Directory.systemTemp.createTemp();
  const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') return dir.path;
    return null;
  });

  _createTmpLibedaxDylibOnMacOS();

  // See: https://pub.dev/packages/shared_preferences#testing
  const evalFileOption = EvalFileOption();
  const bookFileOption = BookFileOption();
  final pref = setPref
      ? <String, String>{
          evalFileOption.prefKey: await evalFileOption.appDefaultValue,
          bookFileOption.prefKey: await bookFileOption.appDefaultValue,
        }
      : <String, String>{};
  SharedPreferences.setMockInitialValues(pref);
}

@isTest
void cleanLibedaxAssets() => _deleteTmpLibedaxDylibOnMacOS();

// See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
void _createTmpLibedaxDylibOnMacOS() {
  if (Platform.isMacOS) File('macos/${EdaxAsset.defaultLibedaxName}').copySync(EdaxAsset.defaultLibedaxName);
}

void _deleteTmpLibedaxDylibOnMacOS() {
  final file = File(EdaxAsset.defaultLibedaxName);
  if (Platform.isMacOS && !file.existsSync()) file.deleteSync();
}
