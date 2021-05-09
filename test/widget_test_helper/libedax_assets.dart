import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pedax/engine/edax_asset.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> prepareLibedaxAssets() async {
  // See: https://flutter.dev/docs/cookbook/persistence/reading-writing-files#testing
  final dir = await Directory.systemTemp.createTemp();
  const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') return dir.path;
    return null;
  });

  _copyDylibForTest();
}

void _copyDylibForTest() =>
    File('${Platform.operatingSystem}/${EdaxAsset.libedaxName}').copySync(EdaxAsset.libedaxName);
