// See: https://flutter.dev/docs/testing/integration-tests

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/pedax_shortcuts/capture_board_image_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/copy_local_info_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/copy_moves_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/paste_moves_shortcut.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/home.dart';
import 'package:pedax/main.dart' as pedax;
import 'package:window_size/window_size.dart';

import '../test/widget_test_helper/fake_shared_preferences.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fakeSharedPreferences(); // always first launch
    mockSecureBookmark();
    setWindowFrame(Rect.fromLTRB(0, 0, pedax.pedaxWindowMinSize.width, pedax.pedaxWindowMinSize.height));
  });
  testWidgets('home', (final tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 10));

    await tester.runAsync(() async {
      await tester.pumpAndSettle(const Duration(seconds: 10));
      await pedax.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final context = tester.element(find.byWidgetPredicate((final widget) => widget is Home));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.freePlayMode), findsOneWidget);

      await waitEdaxSetuped(tester);
      await tester.pump();
      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(PedaxBoard), findsOneWidget);

      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(seconds: 1));
      expectStoneNum(tester, SquareType.black, 4);
      expectStoneCoordinates(tester, ['d5', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 1);
      expectStoneCoordinates(tester, ['d4'], SquareType.white);

      // about pedax
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.about));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();

      // read book file path
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.bookFilePathSetting));
      await tester.pumpAndSettle();
      expect(find.text(l10n.bookFilePathSetting), findsOneWidget);
      await tester.tap(find.text(l10n.cancelOnDialog));
      await tester.pumpAndSettle();

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
      await waitEdaxServerResponse(tester);

      // shortcut cheatsheet
      await tester.tap(find.byIcon(FontAwesomeIcons.keyboard));
      await tester.pumpAndSettle();
      expect(find.text(l10n.shortcutCheatsheet), findsOneWidget);
      await tester.tapAt(const Offset(1, 1));
      await tester.pumpAndSettle();

      // copy local info
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(CopyLocalInfoShorcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // copy board image
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(CaptureBoardImageShorcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // copy moves
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(CopyMovesShorcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();
      final clipboardDataMoves = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipboardDataMoves?.text, 'F5');

      // paste moves
      await Clipboard.setData(const ClipboardData(text: 'c4'));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(PasteMovesShorcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(PasteMovesShorcut.logicalKey);
      await tester.pumpAndSettle();

      // arrange discs mode
      await tester.tap(find.byType(AppBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.arrangeDiscsMode));
      await tester.pumpAndSettle();

      // arrange black disc;
      await tester.tap(findByCoordinate('a8'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['c4', 'd4', 'd5', 'e4', 'a8'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 1);
      expectStoneCoordinates(tester, ['e5'], SquareType.white);
    });
  });
}
