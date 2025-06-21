import 'package:flutter/material.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/home/setting_dialogs/bestpath_count_availability_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/book_file_path_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/hint_step_by_step_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/level_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/n_tasks_setting_dialog.dart';
import 'package:pedax/home/setting_dialogs/shortcut_cheatsheet_dialog.dart';
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

  testWidgets('show AboutDialog', (final tester) async {
    await tester.runAsync(() async {
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.bookFilePathSetting));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.updateSettingOnDialog));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(find.byType(BookFilePathSettingDialog), findsNothing);
      await waitEdaxServerResponse(tester);
    });
  });

  testWidgets('read n-tasks', (final tester) async {
    await tester.runAsync(() async {
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
      tester.view.setLogicalSize(width: 2048, height: 1024);
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
}
