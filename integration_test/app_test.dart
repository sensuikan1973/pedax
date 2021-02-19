// See: https://flutter.dev/docs/testing/integration-tests

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

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({}); // always first launch
  });

  testWidgets('home', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    final context = tester.element(find.byWidgetPredicate((widget) => widget is Home));
    final localizations = AppLocalizations.of(context)!;

    expect(find.text(localizations.analysisMode), findsOneWidget);

    await asyncDelay(tester, const Duration(seconds: 1)); // `book_load` takes too long
    await tester.pump();
    expect(find.byType(Home), findsOneWidget);
    expect(find.byType(PedaxBoard), findsOneWidget);

    await asyncDelay150millisec(tester);
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 2); // e4, d5

    await tester.tap(findByCoordinate('f5'));
    await asyncDelay150millisec(tester);
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
  });
}
