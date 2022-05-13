import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/pedax_shortcuts/pedax_shortcut.dart';
import 'package:pedax/home/setting_dialogs/shortcut_cheatsheet_dialog.dart';
import 'package:pedax/models/board_notifier.dart';

import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import 'widget_test_helper/libedax_assets.dart';
import 'widget_test_helper/shared_preferences_mock.dart';

void main() {
  setUpAll(() async {
    await prepareLibedaxAssets();
    await fakeSharedPreferences();
    mockSecureBookmark();
  });
  setUp(() => Logger.level = Level.nothing);

  group('debugDumpApp for test coverage', () {
    testWidgets('PedaxApp', (final tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const PedaxApp());
        await waitEdaxSetuped(tester);
        debugDumpApp();
        await waitEdaxServerResponse(tester);
      });
    });

    testWidgets('ShortcutCheatsheetDialog', (final tester) async {
      final boardNotifier = BoardNotifier();
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: ShortcutCheatsheetDialog(shortcutList: shortcutList(boardNotifier)),
            localizationsDelegates: PedaxApp.localizationsDelegates,
            supportedLocales: PedaxApp.supportedLocales,
          ),
        );
        await waitEdaxSetuped(tester);
        debugDumpApp();
        await waitEdaxServerResponse(tester);
      });
    });
  });
}
