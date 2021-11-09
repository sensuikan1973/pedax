import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/models/board_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import 'widget_test_helper/libedax_assets.dart';

void main() {
  setUpAll(() async {
    await prepareLibedaxAssets();
    SharedPreferences.setMockInitialValues({}); // first launch
    mockSecureBookmark();
  });
  setUp(() => Logger.level = Level.nothing);
  testWidgets('launch app', (final tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
      await waitEdaxServerResponsed(tester);
    });
  });
}
