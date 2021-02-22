import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/engine/edax_asset.dart';
import 'package:pedax/engine/edax_server.dart';
import 'package:pedax/home/book_file_path_setting_dialog.dart';
import 'package:pedax/home/level_setting_dialog.dart';
import 'package:pedax/home/n_tasks_setting_dialog.dart';

import '../test_helper/edax_server.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  const edaxAsset = EdaxAsset();
  late ReceivePort receivePort;
  late SendPort edaxServerPort;

  setUpAll(() async {
    await prepareLibedaxAssets();
    await edaxAsset.setupDllAndData();
  });

  setUp(() async {
    final initLibedaxParameters = await edaxAsset.buildInitLibEdaxParams();
    receivePort = ReceivePort();
    await Isolate.spawn(
      startEdaxServer,
      StartEdaxServerParams(receivePort.sendPort, await edaxAsset.libedaxPath, initLibedaxParameters),
    );
    final receiveStream = receivePort.asBroadcastStream();
    edaxServerPort = await receiveStream.first as SendPort;
  });

  tearDown(() async {
    receivePort.close();
    // edaxServerPort.send(const ShutdownRequest());
  });

  testWidgets('PedaxApp', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await tester.pumpAndSettle();
      await waitEdaxSetuped(tester);
      debugDumpApp();
    });
  });

  testWidgets('BookFilePathSettingDialog', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        home: BookFilePathSettingDialog(edaxServerPort: edaxServerPort),
        localizationsDelegates: PedaxApp.localizationsDelegates,
      ));
      await tester.pumpAndSettle();
      await waitEdaxSetuped(tester);
      debugDumpApp();
    });
  });

  testWidgets('NTasksSettingDialog', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        home: NTasksSettingDialog(edaxServerPort: edaxServerPort),
        localizationsDelegates: PedaxApp.localizationsDelegates,
      ));
      await tester.pumpAndSettle();
      await waitEdaxSetuped(tester);
      debugDumpApp();
    });
  });

  testWidgets('LevelSettingDialog', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        home: LevelSettingDialog(edaxServerPort: edaxServerPort),
        localizationsDelegates: PedaxApp.localizationsDelegates,
      ));
      await tester.pumpAndSettle();
      await waitEdaxSetuped(tester);
      debugDumpApp();
    });
  });
}
