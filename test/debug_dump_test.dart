import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/engine/edax.dart';
import 'package:pedax/home/book_file_path_setting_dialog.dart';
import 'package:pedax/home/n_tasks_setting_dialog.dart';

import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUp(() async => prepareLibedaxAssets());

  testWidgets('PedaxApp', (tester) async {
    await tester.pumpWidget(const PedaxApp());
    await tester.pumpAndSettle();
    debugDumpApp();
  });

  testWidgets('BookFilePathSettingDialog', (tester) async {
    final edax = Edax();
    await edax.initLibedax();
    await tester.pumpWidget(MaterialApp(
      home: BookFilePathSettingDialog(edax: edax),
      localizationsDelegates: PedaxApp.localizationsDelegates,
      locale: PedaxApp.localeEn,
    ));
    await tester.pumpAndSettle();
    debugDumpApp();
    edax.lib
      ..libedaxTerminate()
      ..closeDll();
  });

  testWidgets('BookFilePathSettingDialog', (tester) async {
    final edax = Edax();
    await edax.initLibedax();
    await tester.pumpWidget(MaterialApp(
      home: NTasksSettingDialog(edax: edax),
      localizationsDelegates: PedaxApp.localizationsDelegates,
      locale: PedaxApp.localeEn,
    ));
    await tester.pumpAndSettle();
    debugDumpApp();
    edax.lib
      ..libedaxTerminate()
      ..closeDll();
  });
}
