import 'package:flutter/material.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'home/home.dart';
import 'models/board_notifier.dart';

const _sharedPrefereceWindowFrameWidthKey = 'windowFrameWidth';
const _sharedPrefereceWindowFrameHeightKey = 'windowFrameHeight';
const _sharedPrefereceWindowFrameLeftKey = 'windowFrameLeft';
const _sharedPrefereceWindowFrameTopKey = 'windowFrameTop';

@immutable
class PedaxApp extends StatefulWidget {
  const PedaxApp({super.key});

  @override
  State<PedaxApp> createState() => _PedaxAppState();

  @visibleForTesting
  static const supportedLocales = [localeEn, localeJa];

  @visibleForTesting
  static const localeEn = Locale('en', ''); // English, no country code

  @visibleForTesting
  static const localeJa = Locale('ja', ''); // Japanese, no country code

  @visibleForTesting
  static const localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static Future<double?> get savedWindowFrameWidth async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPrefereceWindowFrameWidthKey);
  }

  static Future<double?> get savedWindowFrameHeight async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPrefereceWindowFrameHeightKey);
  }

  static Future<double?> get savedWindowFrameLeft async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPrefereceWindowFrameLeftKey);
  }

  static Future<double?> get savedWindowFrameTop async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPrefereceWindowFrameTopKey);
  }
}

// See: https://github.com/leanflutter/window_manager/tree/v0.2.9#usage
class _PedaxAppState extends State<PedaxApp> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final _) => BoardNotifier(),
        child: MaterialApp(
          onGenerateTitle: (final context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(primarySwatch: Colors.brown),
          home: const Home(),
          localizationsDelegates: PedaxApp.localizationsDelegates,
          supportedLocales: PedaxApp.supportedLocales,
          // locale: localeEn,
          // debugShowCheckedModeBanner: false,
        ),
      );

  // NOTE: linux is not supported.
  // https://github.com/leanflutter/window_manager#onwindowresized--macos--windows
  @override
  Future<void> onWindowResized() async {
    final pref = await SharedPreferences.getInstance();
    final windowInfo = await getWindowInfo();
    await pref.setDouble(_sharedPrefereceWindowFrameWidthKey, windowInfo.frame.width);
    await pref.setDouble(_sharedPrefereceWindowFrameHeightKey, windowInfo.frame.height);
  }

  // NOTE: linux is not supported.
  // https://github.com/leanflutter/window_manager/tree/v0.2.9#onwindowmoved--macos--windows
  @override
  Future<void> onWindowMoved() async {
    final pref = await SharedPreferences.getInstance();
    final windowInfo = await getWindowInfo();
    await pref.setDouble(_sharedPrefereceWindowFrameLeftKey, windowInfo.frame.left);
    await pref.setDouble(_sharedPrefereceWindowFrameTopKey, windowInfo.frame.top);
  }

  // https://github.com/leanflutter/window_manager#hidden-at-launch
  @override
  void onWindowFocus() {
    setState(() {});
  }
}
