import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/engine/edax_asset.dart';
import 'package:pedax/engine/edax_server.dart';
import 'package:pedax/home/book_file_path_setting_dialog.dart';
import 'package:pedax/home/hint_step_by_step_setting_dialog.dart';
import 'package:pedax/home/level_setting_dialog.dart';
import 'package:pedax/home/n_tasks_setting_dialog.dart';

import '../test_helper/async_delay.dart';
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
      await delay500millisec(tester);
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
      await delay500millisec(tester);
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
      await delay500millisec(tester);
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
      await delay500millisec(tester);
    });
  });

  testWidgets('HintStepByStepSettingDialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HintStepByStepSettingDialog(),
      localizationsDelegates: PedaxApp.localizationsDelegates,
    ));
    await tester.pumpAndSettle();
    debugDumpApp();
  });
}
