import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/pedax_shortcuts/redo_all_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/redo_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/switch_hint_visibility.dart';
import 'package:pedax/board/pedax_shortcuts/undo_all_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/undo_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/rotate180_shortcut.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/book_file_path_setting_dialog.dart';
import 'package:pedax/home/hint_step_by_step_setting_dialog.dart';
import 'package:pedax/home/level_setting_dialog.dart';
import 'package:pedax/home/n_tasks_setting_dialog.dart';
import 'package:pedax/home/shortcut_cheatsheet_dialog.dart';

import '../test_helper/async_delay.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/localizations.dart';
import 'widget_test_helper/libedax_assets.dart';

Future<void> main() async {
  setUpAll(() async => prepareLibedaxAssets());
  setUp(() => Logger.level = Level.nothing);
  final l10nEn = await loadLocalizations(PedaxApp.localeEn);

  testWidgets('play a game', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);
      expect(find.text(l10nEn.analysisMode), findsOneWidget);

      expect(find.byType(PedaxBoard), findsOneWidget);
      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5

      await tester.tap(findByCoordinate('f4'));
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

      await tester.tap(findByCoordinate('e3'));
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

      await tester.sendKeyEvent(UndoShorcut.logicalKey);
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

      await tester.sendKeyEvent(RedoShorcut.logicalKey);
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

      await tester.sendKeyEvent(UndoAllShorcut.logicalKey);
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.sendKeyEvent(RedoAllShorcut.logicalKey);
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

      await tester.sendKeyEvent(SwitchHintVisibilityShorcut.logicalKey);
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

      await tester.sendKeyEvent(Rotate180Shorcut.logicalKey);
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5); // c3, d3, e3, d5, d6
      expectStoneCoordinate(tester, 'c4', SquareType.black);
      await delay300millisec(tester);
    });
  });

  testWidgets('paste moves', (tester) async {
    const moves = 'f5f6';
    SystemChannels.platform.setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'Clipboard.getData') return const <String, dynamic>{'text': moves};
      return null;
    });
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);

      await tester.pumpAndSettle();
      await delay300millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // e4, d5, f5
      await delay300millisec(tester);
    });
  });

  group('menu events', () {
    testWidgets('show LICENSE page', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.license));
        await tester.pumpAndSettle();
        expect(find.byType(LicensePage), findsOneWidget);
        await delay300millisec(tester);
      });
    });

    testWidgets('show shortcut cheatsheet', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.shortcutCheatsheet));
        await tester.pumpAndSettle();
        expect(find.byType(ShortcutCheatsheetDialog), findsOneWidget);
        await delay300millisec(tester);
      });
    });

    testWidgets('read book file path', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pump();
        expect(find.byType(PedaxApp), findsOneWidget);
        await delay300millisec(tester);
      });
    });

    testWidgets('update book file path with wrong path', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), 'not existing path');
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        expect(find.byType(BookFilePathSettingDialog), findsOneWidget); // nothing happens and dialog isn't closed
        await delay300millisec(tester);
      });
    });

    testWidgets('update book file path with empty path', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.enterText(find.byType(EditableText), ''); // use default book
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(BookFilePathSettingDialog), findsNothing);
        await delay300millisec(tester);
      });
    });

    testWidgets('update book file path as it is', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(BookFilePathSettingDialog), findsNothing);
        await delay300millisec(tester);
      });
    });

    testWidgets('read n-tasks', (tester) async {
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
        await delay300millisec(tester);
      });
    });

    testWidgets('update n-tasks with valid num', (tester) async {
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
        await delay300millisec(tester);
      });
    });

    testWidgets('update n-tasks with invalid num', (tester) async {
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
        await delay300millisec(tester);
      });
    });

    testWidgets('read level', (tester) async {
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
        await delay300millisec(tester);
      });
    });

    testWidgets('update level with valid num', (tester) async {
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
        await delay300millisec(tester);
      });
    });

    testWidgets('update level with invalid num', (tester) async {
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
        await delay300millisec(tester);
      });
    });

    testWidgets('off hint step-by-step', (tester) async {
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
        await delay300millisec(tester);
      });
    });
  });
}
