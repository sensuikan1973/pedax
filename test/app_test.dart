// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUpAll(() async => prepareLibedaxAssets());
  tearDownAll(cleanLibedaxAssets);

  testWidgets('debugDumpApp', (tester) async {
    await tester.pumpWidget(const PedaxApp());
    await tester.pumpAndSettle();
    debugDumpApp();
  });

  testWidgets('launch app', (tester) async {
    await tester.pumpWidget(const PedaxApp());
    await tester.pump();

    // Home Title
    expect(find.text('home'), findsOneWidget);

    // e4, d5
    expectStoneNum(tester, SquareType.black, 2);

    await tester.tap(findByCoordinate('f5'));
    await tester.pump();

    // e4, d5, e5, f5
    expectStoneNum(tester, SquareType.black, 4);

    // Logo
    expect(findByAssetKey('assets/images/pedax_logo.png'), findsOneWidget);
  });
}
