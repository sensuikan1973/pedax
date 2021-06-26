// See: https://flutter.dev/docs/testing/integration-tests

import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/home.dart';
import 'package:pedax/main.dart' as app;
import 'package:pedax/window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({}); // always first launch
    mockSecureBookmark();
    setWindowFrame(Rect.fromLTRB(0, 0, pedaxWindowMinSize.width, pedaxWindowMinSize.height));
  });

  testWidgets('home', (final tester) async {
    await tester.runAsync(() async {
      await app.main();
      await tester.pumpAndSettle();

      final context = tester.element(find.byWidgetPredicate((final widget) => widget is Home));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.analysisMode), findsOneWidget);

      await waitEdaxSetuped(tester);
      await tester.pump();
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(PedaxBoard), findsOneWidget);

      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponsed(tester);
      await tester.pump(const Duration(seconds: 1));
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
    });
  });
}
