import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';

import '../test_helper/async_delay.dart';
import '../test_helper/edax_server.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUpAll(() async {
    await prepareLibedaxAssets();
  });
  setUp(() => Logger.level = Level.nothing);

  testWidgets('PedaxApp', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);
      debugDumpApp();
      await delay300millisec(tester);
    });
  });
}
