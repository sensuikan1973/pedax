import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';
import 'package:pedax/home/setting_dialogs/book_file_path_setting_dialog.dart';

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
    // ignore: deprecated_member_use
    WidgetsBinding.instance.renderView.configuration = TestViewConfiguration.fromView(
      view: WidgetsBinding.instance.renderView.flutterView, // ignore: deprecated_member_use
      size: const Size(2048, 1024),
    ); // https://github.com/flutter/flutter/issues/12994#issuecomment-880199478
    await prepareLibedaxAssets();
    await fakeSharedPreferences(hasEvalFilePath: false, hasBookFilePath: false);
    mockSecureBookmark();
    mockPackageInfo();
    fakeFileSelector();
    mockWindowsManager();
  });
  setUp(() => Logger.level = Level.off);
  final l10nEn = await AppLocalizations.delegate.load(PedaxApp.localeEn);
  testWidgets('launch app', (final tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const PedaxApp());
      await waitEdaxSetuped(tester);

      expectStoneNum(tester, SquareType.black, 2); // e4, d5

      await tester.tap(findByCoordinate('f5'));
      await waitEdaxServerResponse(tester);
      await tester.pump();
      expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5
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
      await tester.tap(find.text(l10nEn.updateSettingOnDialog));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(find.byType(BookFilePathSettingDialog), findsNothing);
      await waitEdaxServerResponse(tester);
    });
  });
}
