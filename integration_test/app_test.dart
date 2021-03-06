// See: https://flutter.dev/docs/testing/integration-tests

import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/home.dart';
import 'package:pedax/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helper/async_delay.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({}); // always first launch
    WidgetsBinding.instance?.renderView.configuration = TestViewConfiguration(size: const Size(1200, 1000));
  });

  testWidgets('home', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1200, 1000);

    await app.main();
    await tester.runAsync(() async {
      await tester.pumpAndSettle();

      final context = tester.element(find.byWidgetPredicate((widget) => widget is Home));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.analysisMode), findsOneWidget);

      await waitEdaxSetuped(tester);
      await tester.pump();
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(PedaxBoard), findsOneWidget);

      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
    });
  });
}
