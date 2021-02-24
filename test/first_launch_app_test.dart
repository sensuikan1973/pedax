import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/async_delay.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUp(() async => prepareLibedaxAssets(setPref: false)); // when first launch, pref is empty.
  testWidgets('launch app', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await tester.pumpAndSettle();
      await waitEdaxSetuped(tester);

      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
      await Future<void>.delayed(const Duration(seconds: 1)); // wait isolate process
    });
  });
}
