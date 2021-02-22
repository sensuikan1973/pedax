import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_board.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/book_file_path_setting_dialog.dart';
import 'package:pedax/home/level_setting_dialog.dart';
import 'package:pedax/home/n_tasks_setting_dialog.dart';

import '../test_helper/async_delay.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/localizations.dart';
import 'widget_test_helper/libedax_assets.dart';

Future<void> main() async {
  setUpAll(() async => prepareLibedaxAssets());
  final l10nEn = await loadLocalizations(PedaxApp.localeEn);

  testWidgets('play a game', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.analysisMode), findsOneWidget);

      await waitEdaxSetuped(tester);

      expect(find.byType(PedaxBoard), findsOneWidget);
      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await delay400millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5

      await tester.tap(findByCoordinate('f4'));
      await delay400millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

      await tester.tap(findByCoordinate('e3'));
      await delay400millisec(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5
      await Future<void>.delayed(const Duration(seconds: 4));
    });
  });

  group('menu events', () {
    testWidgets('show LICENSE page', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.license));
        await tester.pumpAndSettle();
        expect(find.byType(LicensePage), findsOneWidget);
        await delay400millisec(tester);
      });
    });

    testWidgets('read book file path', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.bookFilePathSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pump();
        expect(find.byType(PedaxApp), findsOneWidget);
        await delay400millisec(tester);
      });
    });

    testWidgets('update book file path with wrong path', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

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
        await delay400millisec(tester);
      });
    });

    testWidgets('update book file path with empty path', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

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
        await delay400millisec(tester);
      });
    });

    testWidgets('update book file path as it is', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

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
        await delay400millisec(tester);
      });
    });

    testWidgets('read n-tasks', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

        await waitEdaxSetuped(tester);
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.nTasksSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.nTasksSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pump();
        expect(find.byType(PedaxApp), findsOneWidget);
        await delay400millisec(tester);
      });
    });

    testWidgets('update n-tasks', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

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
        await delay400millisec(tester);
      });
    });

    testWidgets('read level', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

        await waitEdaxSetuped(tester);

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.levelSetting));
        await tester.pumpAndSettle();
        expect(find.text(l10nEn.levelSetting), findsOneWidget);
        await tester.tap(find.text(l10nEn.cancelOnDialog));
        await tester.pump();
        expect(find.byType(PedaxApp), findsOneWidget);
        await delay400millisec(tester);
      });
    });

    testWidgets('update level', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await tester.pumpAndSettle();

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
        await delay400millisec(tester);
      });
    });
  });
}
