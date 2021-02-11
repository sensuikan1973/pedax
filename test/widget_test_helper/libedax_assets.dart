import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pedax/engine/edax.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> prepareLibedaxAssets() async {
  // See: https://flutter.dev/docs/cookbook/persistence/reading-writing-files#testing
  final dir = await Directory.systemTemp.createTemp();
  const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') return dir.path;
    return null;
  });
  // See: https://pub.dev/packages/shared_preferences#testing
  final pref = <String, String>{
    Edax.evalFilePathPrefKey: '${dir.path}/${Edax.defaultEvalFileName}',
    Edax.bookFilePathPrefKey: '${dir.path}/${Edax.defaultBookFileName}',
  };
  SharedPreferences.setMockInitialValues(pref);

  _createTmpLibedaxDylibOnMacOS();
}

void cleanLibedaxAssets() => _deleteTmpLibedaxDylibOnMacOS();

// See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
void _createTmpLibedaxDylibOnMacOS() {
  if (Platform.isMacOS) File('macos/${Edax.defaultLibedaxName}').copySync(Edax.defaultLibedaxName);
}

void _deleteTmpLibedaxDylibOnMacOS() {
  if (Platform.isMacOS) File(Edax.defaultLibedaxName).deleteSync();
}
