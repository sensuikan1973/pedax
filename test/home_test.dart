import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/pedax_shortcuts/redo_all_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/redo_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/rotate180_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/switch_hint_visibility.dart';
import 'package:pedax/board/pedax_shortcuts/undo_all_shortcut.dart';
import 'package:pedax/board/pedax_shortcuts/undo_shortcut.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/bestpath_count_availability_setting_dialog.dart';
import 'package:pedax/home/book_file_path_setting_dialog.dart';
import 'package:pedax/home/hint_step_by_step_setting_dialog.dart';
import 'package:pedax/home/level_setting_dialog.dart';
import 'package:pedax/home/n_tasks_setting_dialog.dart';
import 'package:pedax/home/shortcut_cheatsheet_dialog.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import 'widget_test_helper/libedax_assets.dart';
import 'widget_test_helper/shared_preferences_mock.dart';

Future<void> main() async {
  setUpAll(() async {
    await prepareLibedaxAssets();
    await mockSharedPreferences();
    mockSecureBookmark();
  });
  setUp(() async {
    Logger.level = Level.nothing;
    // For `runAsync`, ensure asynchronous events have completed.
    await Future<void>.delayed(const Duration(seconds: 1));
  });
  final l10nEn = await AppLocalizations.delegate.load(PedaxApp.localeEn);

  group('play a game', () {
    testWidgets('a game without pass', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);
        expect(find.text(l10nEn.analysisMode), findsOneWidget);

        expect(find.byType(PedaxBoard), findsOneWidget);
        expectStoneNum(tester, SquareType.black, 2); // e4, d5

        await tester.tap(findByCoordinate('f5'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5

        await tester.tap(findByCoordinate('f4'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

        await tester.tap(findByCoordinate('e3'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.sendKeyEvent(UndoShorcut.logicalKeyU);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

        await tester.sendKeyEvent(RedoShorcut.logicalKeyR);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.sendKeyEvent(UndoShorcut.logicalKeyArrowLeft);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

        await tester.sendKeyEvent(RedoShorcut.logicalKeyArrowRight);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.tap(find.byIcon(FontAwesomeIcons.angleLeft));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

        await tester.tap(find.byIcon(FontAwesomeIcons.angleRight));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.sendKeyEvent(UndoAllShorcut.logicalKey);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 2); // e4, d5

        await tester.sendKeyEvent(RedoAllShorcut.logicalKey);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.tap(find.byIcon(FontAwesomeIcons.angleDoubleLeft));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 2); // e4, d5

        await tester.tap(find.byIcon(FontAwesomeIcons.angleDoubleRight));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.sendKeyEvent(SwitchHintVisibilityShorcut.logicalKey);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

        await tester.sendKeyEvent(Rotate180Shorcut.logicalKey);
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.black, 5); // c3, d3, e3, d5, d6
        expectStoneCoordinate(tester, 'c4', SquareType.black);
        await waitEdaxServerResponsed(tester);
      });
    });

    testWidgets('a game with pass', (final tester) async {
      // REF: https://www.hasera.net/othello/mame006.html
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(findByCoordinate('f5'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('f6'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('d3'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('g5'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('h5'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('h4'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('f7'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('h6')); // black pass internaly in engine.
        await waitEdaxServerResponsed(tester);
        await tester.pump();

        await tester.tap(findByCoordinate('e7'));
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.white, 6); // h4, h5, h6, g5, f6, e7

        await tester.tap(find.byIcon(FontAwesomeIcons.angleLeft)); // skip pass internaly in engine.
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.white, 4); // h4, h5, h6, g5

        await tester.tap(find.byIcon(FontAwesomeIcons.angleRight)); // skip pass internaly in engine.
        await waitEdaxServerResponsed(tester);
        await tester.pump();
        expectStoneNum(tester, SquareType.white, 6); // h4, h5, h6, g5, f6, e7
        await waitEdaxServerResponsed(tester);
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
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await tester.pumpAndSettle();
      await waitEdaxServerResponsed(tester);
      await tester.pumpAndSettle();
      expectStoneNum(tester, SquareType.black, 3); // e4, d5, f5

      // copy
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
      });
    });

    testWidgets('show shortcut cheatsheet', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.shortcutCheatsheet));
        await tester.pumpAndSettle();
        expect(find.byType(ShortcutCheatsheetDialog), findsOneWidget);
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await tester.tap(find.text(l10nEn.updateSettingOnDialog));
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(find.byType(BookFilePathSettingDialog), findsNothing);
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
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
        await waitEdaxServerResponsed(tester);
      });
    });

    testWidgets('on bestpath count availability', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bestpathCountAvailabilitySetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bestpathCountAvailabilitySetting), findsOneWidget);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        expect(find.byType(BestpathCountAvailabilitySettingDialog), findsNothing);
        await waitEdaxServerResponsed(tester);
      });
    });
  });
}
