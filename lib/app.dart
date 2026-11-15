import 'package:material_ui/material_ui.dart';
import 'package:pedax/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'home/home.dart';
import 'models/board_notifier.dart';

const _sharedPreferenceWindowFrameWidthKey = 'windowFrameWidth';
const _sharedPreferenceWindowFrameHeightKey = 'windowFrameHeight';
const _sharedPreferenceWindowFrameLeftKey = 'windowFrameLeft';
const _sharedPreferenceWindowFrameTopKey = 'windowFrameTop';

@immutable
class PedaxApp extends StatefulWidget {
  const PedaxApp({super.key});

  @override
  State<PedaxApp> createState() => _PedaxAppState();

  @visibleForTesting
  static const localizationsDelegates = [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates];

  static Future<double?> get savedWindowFrameWidth async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPreferenceWindowFrameWidthKey);
  }

  static Future<double?> get savedWindowFrameHeight async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPreferenceWindowFrameHeightKey);
  }

  static Future<double?> get savedWindowFrameLeft async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPreferenceWindowFrameLeftKey);
  }

  static Future<double?> get savedWindowFrameTop async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_sharedPreferenceWindowFrameTopKey);
  }
}

class _PedaxAppState extends State<PedaxApp> {
  late final ListenerId _windowListenerId;

  @override
  void initState() {
    super.initState();
    _windowListenerId = WindowManager.instance.addListener(_onWindowEvent);
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(_windowListenerId);
    super.dispose();
  }

  Future<void> _onWindowEvent(WindowEvent event) async {
    if (event is WindowResizedEvent) {
      await _saveWindowSize();
    } else if (event is WindowMovedEvent) {
      await _saveWindowPosition();
    } else if (event is WindowFocusedEvent && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => BoardNotifier(),
    child: MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const Home(),
      localizationsDelegates: PedaxApp.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // locale: localeEn,
      // debugShowCheckedModeBanner: false,
    ),
  );

  Future<void> _saveWindowSize() async {
    final pref = await SharedPreferences.getInstance();
    final windowInfo = await getWindowInfo();
    await pref.setDouble(_sharedPreferenceWindowFrameWidthKey, windowInfo.frame.width);
    await pref.setDouble(_sharedPreferenceWindowFrameHeightKey, windowInfo.frame.height);
  }

  Future<void> _saveWindowPosition() async {
    final pref = await SharedPreferences.getInstance();
    final windowInfo = await getWindowInfo();
    await pref.setDouble(_sharedPreferenceWindowFrameLeftKey, windowInfo.frame.left);
    await pref.setDouble(_sharedPreferenceWindowFrameTopKey, windowInfo.frame.top);
  }
}
