import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  group('with libedax assets pref', () {
    setUp(() async => prepareLibedaxAssets());
    testWidgets('launch app', _launchApp);
  });

  group('with libedax assets pref', () {
    setUp(() async => prepareLibedaxAssets(setPref: false));
    testWidgets('launch app', _launchApp);
  });
}

Future<void> _launchApp(WidgetTester tester) async {
  await tester.pumpWidget(const PedaxApp());
  await tester.pumpAndSettle();

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
}
