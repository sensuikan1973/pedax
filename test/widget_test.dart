// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/engine/edax.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async => _mockLibedaxAssets());
  tearDownAll(() {
    if (Platform.isMacOS) _deleteTmpLibedaxDylib();
  });

  testWidgets('Counter increments smoke test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PedaxApp());

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Home Title
    expect(find.text('home'), findsOneWidget);

    // d4 e4
    expect(find.textContaining('O *'), findsOneWidget);
  });
}

Future<void> _mockLibedaxAssets() async {
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

  if (Platform.isMacOS) _createTmpLibedaxDylib();
}

// See: https://flutter.dev/docs/development/platform-integration/c-interop#compiled-dynamic-library-macos
void _createTmpLibedaxDylib() => File('macos/${Edax.defaultLibedaxName}').copySync(Edax.defaultLibedaxName);
void _deleteTmpLibedaxDylib() => File(Edax.defaultLibedaxName).deleteSync();
