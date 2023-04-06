import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
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
import 'package:pedax/home/setting_dialogs/bestpath_count_availability_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/book_file_path_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/hint_step_by_step_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/level_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/n_tasks_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/shortcut_cheatsheet_dialog.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import 'widget_test_helper/fake_file_selector.dart';
import 'widget_test_helper/fake_shared_preferences.dart';
import 'widget_test_helper/libedax_assets.dart';
import 'widget_test_helper/mock_package_info.dart';

Future<void> main() async {
  setUpAll(() async {
    await prepareLibedaxAssets();
    await fakeSharedPreferences();
    mockSecureBookmark();
    mockPackageInfo();
    fakeFileSelector();
  });
  setUp(() async {
    Logger.level = Level.nothing;
  });
  final l10nEn = await AppLocalizations.delegate.load(PedaxApp.localeEn);

  group('play a game', () {
    testWidgets('a game without pass', (final tester) async {
      await tester.runAsync(() async {
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

        await tester.sendKeyEvent(UndoShorcut.logicalKeyU);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 3);
        expectStoneCoordinates(tester, ['d5', 'e5', 'f5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 3);
        expectStoneCoordinates(tester, ['d4', 'e4', 'f4'], SquareType.white);

        await tester.sendKeyEvent(RedoShorcut.logicalKeyR);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5);
        expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

        await tester.sendKeyEvent(UndoShorcut.logicalKeyArrowLeft);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 3);
        expectStoneCoordinates(tester, ['d5', 'e5', 'f5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 3);
        expectStoneCoordinates(tester, ['d4', 'e4', 'f4'], SquareType.white);

        await tester.sendKeyEvent(RedoShorcut.logicalKeyArrowRight);
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

        await tester.sendKeyEvent(UndoAllShorcut.logicalKey);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 2);
        expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

        await tester.sendKeyEvent(RedoAllShorcut.logicalKey);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5);
        expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

        await tester.tap(find.byIcon(FontAwesomeIcons.anglesLeft));
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 2);
        expectStoneCoordinates(tester, ['e4', 'd5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

        await tester.tap(find.byIcon(FontAwesomeIcons.anglesRight));
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5);
        expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

        await tester.sendKeyEvent(SwitchHintVisibilityShorcut.logicalKey);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5);
        expectStoneCoordinates(tester, ['d5', 'e3', 'e4', 'e5', 'f5'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'f4'], SquareType.white);

        await tester.sendKeyEvent(Rotate180Shorcut.logicalKey);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5);
        expectStoneCoordinates(tester, ['c4', 'd4', 'd5', 'd6', 'e4'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['c5', 'e5'], SquareType.white);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(NewShorcut.logicalKey);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 2);
        expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(InitShorcut.logicalKey);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await waitEdaxServerResponse(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 2);
        expectStoneCoordinates(tester, ['d5', 'e4'], SquareType.black);
        expectStoneNum(tester, SquareType.white, 2);
        expectStoneCoordinates(tester, ['d4', 'e5'], SquareType.white);
      });
    });

    testWidgets('a game with pass', (final tester) async {
      await tester.runAsync(() async {
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
      });
    });
  });

  testWidgets('paste moves, and copy moves', (final tester) async {
    const moves = 'f5f6';
    SystemChannels.platform.setMockMethodCallHandler((final methodCall) async {
      if (methodCall.method == 'Clipboard.getData') return const <String, dynamic>{'text': moves};
      return null;
    });
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      // paste
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(PasteMovesShorcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await tester.pumpAndSettle();
      await waitEdaxServerResponse(tester);
      await tester.pumpAndSettle();
      expectStoneNum(tester, SquareType.black, 3); // e4, d5, f5

      // copy
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(CopyMovesShorcut.logicalKey);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await waitEdaxServerResponse(tester);
    });
  });

  group('menu events', () {
    testWidgets('show AboutDialog', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.about));
        await tester.pumpAndSettle();
        expect(find.byType(AboutDialog), findsOneWidget);
        expect(find.text('pedax.test'), findsOneWidget);
        expect(find.text('0.0.0'), findsOneWidget);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('show shortcut cheatsheet', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(FontAwesomeIcons.keyboard));
        await tester.pumpAndSettle();
        expect(find.byType(ShortcutCheatsheetDialog), findsOneWidget);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('read book file path', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pumpAndSettle();
        expect(find.byType(PedaxApp), findsOneWidget);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update book file path as it is', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        // await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        // await tester.pumpAndSettle();
        // await Future<void>.delayed(const Duration(seconds: 1));
        // expect(find.byType(BookFilePathSettingDialog), findsNothing);
        // await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('read n-tasks', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.nTasksSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.nTasksSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pump();
        expect(find.byType(PedaxApp), findsOneWidget);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update n-tasks with valid num', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.nTasksSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.nTasksSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 1.toString());
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(NTasksSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update n-tasks with invalid small num', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.nTasksSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.nTasksSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), (-1).toString());
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(NTasksSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update n-tasks with invalid large num', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.nTasksSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.nTasksSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 99999.toString());
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(NTasksSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('read level', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.levelSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.levelSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pump();
        expect(find.byType(PedaxApp), findsOneWidget);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update level with valid num', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.levelSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.levelSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 1.toString());
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(LevelSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update level with invalid num', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.levelSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.levelSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), (-1).toString());
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(LevelSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('off hint step-by-step', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.hintStepByStepSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.hintStepByStepSetting), findsOneWidget);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        expect(find.byType(HintStepByStepSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('on bestpath count availability', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bestpathCountSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bestpathCountSetting), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        expect(find.byType(BestpathCountSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update bestpath count player lower limit', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bestpathCountSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bestpathCountSetting), findsOneWidget);
        expect(find.byType(EditableText), findsNWidgets(2));
        final playerLowerLimitTextForm = find.byType(EditableText).at(0);
        await tester.enterText(playerLowerLimitTextForm, 1.toString());
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        expect(find.byType(BestpathCountSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('update bestpath count opponent lower limit', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bestpathCountSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bestpathCountSetting), findsOneWidget);
        expect(find.byType(EditableText), findsNWidgets(2));
        final opponentLowerLimitTextForm = find.byType(EditableText).at(1);
        await tester.enterText(opponentLowerLimitTextForm, 1.toString());
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        expect(find.byType(BestpathCountSettingDialog), findsNothing);
        await waitEdaxServerResponse(tester);
      });
    });
  });
}
