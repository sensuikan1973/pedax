// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUpAll(() async => prepareLibedaxAssets());
  tearDownAll(cleanLibedaxAssets);

  testWidgets('launch app', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PedaxApp());

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Home Title
    expect(find.text('home'), findsOneWidget);

    expectStoneNum(tester, SquareType.black, 2);

    // Logo
    expect(findByAssetKey('assets/images/pedax_logo.png'), findsOneWidget);
  });
}
