import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_shortcuts/init_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/new_shortcut.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import 'widget_test_helper/file_selector_mock.dart';
import 'widget_test_helper/libedax_assets.dart';
import 'widget_test_helper/shared_preferences_mock.dart';
import 'widget_test_helper/url_launcher_mock.dart';

Future<void> main() async {
  setUpAll(() async {
    await prepareLibedaxAssets();
    await mockSharedPreferences();
    mockSecureBookmark();
    mockUrlLauncher();
    mockFileSelector();
  });
  setUp(() async {
    Logger.level = Level.nothing;
    // For `runAsync`, ensure asynchronous events have completed.
    await Future<void>.delayed(const Duration(seconds: 1));
  });
  final l10nEn = await AppLocalizations.delegate.load(PedaxApp.localeEn);

  testWidgets('arrange discs, and play', (final tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      await tester.tap(find.byType(AppBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.arrangeDiscsMode));
      await tester.pumpAndSettle();

      // arrange black disc
      await tester.tap(find.byKey(const Key('switchArrangeTargetToBlack')));
      await tester.pumpAndSettle();
      await tester.tap(findByCoordinate('h8'));
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // d5, e4, h8
      expectStoneNum(tester, SquareType.white, 2); // d4, e5

      // arrange white disc
      await tester.tap(find.byKey(const Key('switchArrangeTargetToWhite')));
      await tester.pumpAndSettle();
      await tester.tap(findByCoordinate('a8'));
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // d5, e4, h8
      expectStoneNum(tester, SquareType.white, 3); // d4, e5, a8

      // arrange empty disc
      await tester.tap(find.byKey(const Key('switchArrangeTargetToEmpty')));
      await tester.pumpAndSettle();
      await tester.tap(findByCoordinate('d4'));
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // d5, e4, h8
      expectStoneNum(tester, SquareType.white, 2); // e5, a8

      // switch board mode to freePlay
      await tester.tap(find.byType(AppBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.freePlayMode));
      await tester.pumpAndSettle();

      // move f5
      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.white, 1); // a8
      expectStoneNum(tester, SquareType.black, 5); // d5, e4, h8, e5, f5

      // edaxNew
      await tester.sendKeyEvent(NewShorcut.logicalKey);
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.white, 2); // e5, a8
      expectStoneNum(tester, SquareType.black, 3); // d5, e4, h8
      await waitEdaxServerResponsed(tester);

      // edaxInit
      await tester.sendKeyEvent(InitShorcut.logicalKey);
      await waitEdaxServerResponsed(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.white, 2); // d4, e5
      expectStoneNum(tester, SquareType.black, 2); // d5, e4
      await waitEdaxServerResponsed(tester);
    });
  });
}
