import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';

import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUp(() async => prepareLibedaxAssets());

  testWidgets('debugDumpApp', (tester) async {
    await tester.pumpWidget(const PedaxApp());
    await tester.pumpAndSettle();
    debugDumpApp();
  });
}
