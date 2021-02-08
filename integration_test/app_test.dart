// This is a basic Flutter integration test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// See: https://flutter.dev/docs/testing/integration-tests

// @dart = 2.11
// See: https://github.com/flutter/flutter/issues/71379
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/main.dart' as app;

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launch app', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    // Home Title
    expect(find.text('home'), findsOneWidget);

    // e4, d5
    expectStoneNum(tester, SquareType.black, 2);

    await tester.tap(findByCoordinate('f5'));
    await tester.pumpAndSettle();

    // e4, d5, e5, f5
    expectStoneNum(tester, SquareType.black, 4);

    // Logo
    expect(findByAssetKey('assets/images/pedax_logo.png'), findsOneWidget);
  });
}
