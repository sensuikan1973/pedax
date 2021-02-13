// See: https://flutter.dev/docs/testing/integration-tests

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({}); // always first launch
  });

  testWidgets('home', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    final l10nEn = await loadLocalizations(PedaxApp.localeEn);

    expect(find.text(l10nEn.homeTitle), findsOneWidget);
    expect(findByAssetKey('assets/images/pedax_logo.png'), findsOneWidget);

    expectStoneNum(tester, SquareType.black, 2); // e4, d5

    await tester.tap(findByCoordinate('f5'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
  });
}
