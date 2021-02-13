import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUp(() async => prepareLibedaxAssets());
  testWidgets('launch app', (tester) async {
    await tester.pumpWidget(const PedaxApp());
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(findByAssetKey('assets/images/pedax_logo.png'), findsOneWidget);

    expectStoneNum(tester, SquareType.black, 2); // e4, d5

    await tester.tap(findByCoordinate('f5'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5

    await tester.tap(findByCoordinate('f4'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

    await tester.tap(findByCoordinate('e3'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5
  });
}
