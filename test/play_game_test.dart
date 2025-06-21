import 'package:flutter/services.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/pedax_shortcuts/copy_moves_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/init_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/new_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/paste_moves_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/redo_all_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/redo_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/rotate180_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/switch_hint_visibility_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/undo_all_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/undo_shortcut.dart';
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
    await prepareLibedaxAssets();
    await fakeSharedPreferences();
    mockSecureBookmark();
    mockPackageInfo();
    fakeFileSelector();
    mockWindowsManager();
  });
  setUp(() => Logger.level = Level.debug);
  final l10nEn = await AppLocalizations.delegate.load(PedaxApp.localeEn);

  testWidgets('a game without pass', (final tester) async {
    await tester.runAsync(() async {
      tester.view.setLogicalSize(width: 2048, height: 1024);
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);
      expect(find.text(l10nEn.freePlayMode), findsOneWidget);

      expect(find.byType(PedaxBoard), findsOneWidget);
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4);
      expectStoneCoordinates(tester, ['d5', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 1);
      expectStoneCoordinates(tester, ['d4'], SquareType.white);

      await tester.tap(findByCoordinate('f4'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e4', 'f4'], SquareType.white);

      await tester.tap(findByCoordinate('e3'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(UndoShortcut.logicalKeyU);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(RedoShortcut.logicalKeyR);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(UndoShortcut.logicalKeyArrowLeft);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(RedoShortcut.logicalKeyArrowRight);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.tap(find.byIcon(FontAwesomeIcons.angleLeft));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e4', 'f4'], SquareType.white);

      await tester.tap(find.byIcon(FontAwesomeIcons.angleRight));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(UndoAllShortcut.logicalKey);
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

      await tester.sendKeyEvent(RedoAllShortcut.logicalKey);
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.tap(find.byIcon(FontAwesomeIcons.anglesLeft));
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['e4', 'd5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

      await tester.tap(find.byIcon(FontAwesomeIcons.anglesRight));
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(SwitchHintVisibilityShortcut.logicalKey);
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

      await tester.sendKeyEvent(Rotate180Shortcut.logicalKey);
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['c4', 'd4', 'd5', 'd6', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['c5', 'e5'], SquareType.white);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(NewShortcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(InitShortcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await waitEdaxServerResponse(tester);
      await tester.pump(const Duration(microseconds: 300));
      expectStoneNum(tester, SquareType.black, 2);
      expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

      await waitEdaxServerResponse(tester);
    });
  });

  testWidgets('a game with pass', (final tester) async {
    await tester.runAsync(() async {
      tester.view.setLogicalSize(width: 2048, height: 1024);
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      // REF: https://www.hasera.net/othello/mame006.html
      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4);
      expectStoneCoordinates(tester, ['d5', 'e4', 'e5', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 1);
      expectStoneCoordinates(tester, ['d4'], SquareType.white);

      await tester.tap(findByCoordinate('f6'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3);
      expectStoneCoordinates(tester, ['d5', 'e4', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['d4', 'e5', 'f6'], SquareType.white);

      await tester.tap(findByCoordinate('d3'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'f5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['e5', 'f6'], SquareType.white);

      await tester.tap(findByCoordinate('g5'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 4);
      expectStoneCoordinates(tester, ['e5', 'f5', 'f6', 'g5'], SquareType.white);

      await tester.tap(findByCoordinate('h5'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 8);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'g5', 'h5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 1);
      expectStoneCoordinates(tester, ['f6'], SquareType.white);

      await tester.tap(findByCoordinate('h4'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 7);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'h5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 3);
      expectStoneCoordinates(tester, ['f6', 'g5', 'h4'], SquareType.white);

      await tester.tap(findByCoordinate('f7'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 9);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'f6', 'f7', 'h5'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 2);
      expectStoneCoordinates(tester, ['g5', 'h4'], SquareType.white);

      await tester.tap(findByCoordinate('h6')); // black pass internally in engine.
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 8);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'f6', 'f7'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 4);
      expectStoneCoordinates(tester, ['g5', 'h4', 'h5', 'h6'], SquareType.white);

      await tester.tap(findByCoordinate('e7'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 7);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'f7'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 6);
      expectStoneCoordinates(tester, ['e7', 'f6', 'g5', 'h4', 'h5', 'h6'], SquareType.white);

      await tester.tap(find.byIcon(FontAwesomeIcons.angleLeft)); // skip pass internally in engine.
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 8);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'f6', 'f7'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 4);
      expectStoneCoordinates(tester, ['g5', 'h4', 'h5', 'h6'], SquareType.white);

      await tester.tap(find.byIcon(FontAwesomeIcons.angleRight)); // skip pass internally in engine.
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 7);
      expectStoneCoordinates(tester, ['d3', 'd4', 'd5', 'e4', 'e5', 'f5', 'f7'], SquareType.black);
      expectStoneNum(tester, SquareType.white, 6);
      expectStoneCoordinates(tester, ['e7', 'f6', 'g5', 'h4', 'h5', 'h6'], SquareType.white);

      await waitEdaxServerResponse(tester);
    });
  });

  testWidgets('paste moves, and copy moves', (final tester) async {
    const moves = 'f5f6';
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (final methodCall) async {
      if (methodCall.method == 'Clipboard.getData') return const <String, dynamic>{'text': moves};
      return null;
    });
    await tester.runAsync(() async {
      tester.view.setLogicalSize(width: 2048, height: 1024);
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      // paste
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(PasteMovesShortcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await tester.pumpAndSettle();
      await waitEdaxServerResponse(tester);
      await tester.pumpAndSettle();
      expectStoneNum(tester, SquareType.black, 3); // e4, d5, f5

      // copy
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(CopyMovesShortcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await waitEdaxServerResponse(tester);
    });
  });
}
