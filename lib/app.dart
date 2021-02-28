import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'home/home.dart';
import 'models/board_notifier.dart';

@immutable
class PedaxApp extends StatelessWidget {
  const PedaxApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(primarySwatch: Colors.brown),
        home: ChangeNotifierProvider(
          create: (_) => BoardNotifier(),
          child: const Home(),
        ),
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        // locale: localeEn,
        // debugShowCheckedModeBanner: false,
      );

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
}
