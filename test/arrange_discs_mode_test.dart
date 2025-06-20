import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_shortcuts/init_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/new_shortcut.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import '../test_helper/windows_manager_mock.dart';
import 'widget_test_helper/fake_file_selector.dart';
import 'widget_test_helper/fake_shared_preferences.dart';
import 'widget_test_helper/libedax_assets.dart';
import 'widget_test_helper/mock_package_info.dart';

Future<void> main() async {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.platformDispatcher.views.first.configuration = TestViewConfiguration.fromView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      size: const Size(2048, 1024),
    ); // https://github.com/flutter/flutter/issues/12994#issuecomment-880199478
    await prepareLibedaxAssets();
    await fakeSharedPreferences();
    mockSecureBookmark();
    mockPackageInfo();
    fakeFileSelector();
    mockWindowsManager();
  });
  setUp(() => Logger.level = Level.debug);
  final l10nEn = await AppLocalizations.delegate.load(PedaxApp.localeEn);

  testWidgets('arrange discs, and play', (final tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      await tester.tap(find.byType(AppBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.arrangeDiscsMode));
      await tester.pumpAndSettle();

      // arrange white disc
      await tester.tap(find.byKey(const Key('switchArrangeTargetToWhite')));
      await tester.pumpAndSettle();
      await tester.tap(findByCoordinate('a8'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e5', 'a8'], SquareType.white);

      // arrange black disc
      await tester.tap(find.byKey(const Key('switchArrangeTargetToBlack')));
      await tester.pumpAndSettle();
      await tester.tap(findByCoordinate('h8'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e4', 'h8'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e5', 'a8'], SquareType.white);

      // arrange empty disc
      await tester.tap(find.byKey(const Key('switchArrangeTargetToEmpty')));
      await tester.pumpAndSettle();
      await tester.tap(findByCoordinate('d4'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e4', 'h8'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['e5', 'a8'], SquareType.white);

      // switch board mode to freePlay
      await tester.tap(find.byType(AppBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.freePlayMode));
      await tester.pumpAndSettle();

      // move f5
      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e4', 'e5', 'f5', 'h8'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 1);
      expectStoneCoordinates(tester, ['a8'], SquareType.white);

      // edaxNew
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(NewShortcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e4', 'h8'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['e5', 'a8'], SquareType.white);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(InitShortcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);
    });
  });
}
