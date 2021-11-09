// See: https://flutter.dev/docs/testing/integration-tests

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/home.dart';
import 'package:pedax/home/setting_dialogs/level_setting_dialog.dart';
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
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.freePlayMode), findsOneWidget);

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

      // update level setting
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.levelSetting));
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSetting), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 1.toString());
      await tester.tap(find.text(l10n.updateSettingOnDialog));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(find.byType(LevelSettingDialog), findsNothing);
      await waitEdaxServerResponsed(tester);

      // copy moves
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      final clipboardData = await Clipboard.getData('text/plain');
      expect(clipboardData?.text, 'F5');
    });
  });
}
