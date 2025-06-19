import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/board_finder.dart';
import '../test_helper/edax_server.dart';
import '../test_helper/secure_bookmark_mock.dart';
import '../test_helper/windows_manager_mock.dart';
import 'widget_test_helper/fake_shared_preferences.dart';
import 'widget_test_helper/fake_file_selector.dart';
import 'widget_test_helper/libedax_assets.dart';
import 'widget_test_helper/mock_package_info.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.instance;
    binding.window.physicalSizeTestValue = const Size(2048, 1024);
    binding.window.devicePixelRatioTestValue = 1.0;
    await prepareLibedaxAssets();
    await fakeSharedPreferences();
    mockSecureBookmark();
    mockPackageInfo();
    fakeFileSelector();
    mockWindowsManager();
  });
  setUp(() => Logger.level = Level.debug);
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
}
