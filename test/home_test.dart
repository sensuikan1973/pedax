import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/app.dart';
import 'package:pedax/board/square.dart';

import '../test_helper/asset_image_finder.dart';
import '../test_helper/board_finder.dart';
import '../test_helper/localizations.dart';
import 'widget_test_helper/libedax_assets.dart';

Future<void> main() async {
  setUp(() async => prepareLibedaxAssets());
  final l10nEn = await loadLocalizations(PedaxApp.localeEn);

  testWidgets('play a game', (tester) async {
    await tester.pumpWidget(const PedaxApp());
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.homeTitle), findsOneWidget);
    expect(findByAssetKey('assets/images/pedax_logo.png'), findsOneWidget);

    expectStoneNum(tester, SquareType.black, 2); // e4, d5

    await tester.tap(findByCoordinate('f5'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 4); // e4, d5, e5, f5

    await tester.tap(findByCoordinate('f4'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 3); // d5, e5, f5

    await tester.tap(findByCoordinate('e3'));
    await tester.pump();
    expectStoneNum(tester, SquareType.black, 5); // e3, e4, d5, e5, f5

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nEn.license));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  group('menu events', () {
    testWidgets('show LICENSE page', (tester) async {
      await tester.pumpWidget(const PedaxApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.license));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('read book file path', (tester) async {
      await tester.pumpWidget(const PedaxApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.bookFilePathSetting));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
      await tester.tap(find.text(l10nEn.cancelOnDialog));
      await tester.pump();
      expect(find.byType(PedaxApp), findsOneWidget);
    });

    testWidgets('update book file path', (tester) async {
      await tester.pumpWidget(const PedaxApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.bookFilePathSetting));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.bookFilePathSetting), findsOneWidget);
      await tester.tap(find.text(l10nEn.updateSettingOnDialog)); // update as it is
      await tester.pump();
      expect(find.byType(PedaxApp), findsOneWidget);
    });
  });
}
