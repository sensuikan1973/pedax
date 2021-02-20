import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home/home.dart';

class PedaxApp extends StatelessWidget {
  const PedaxApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(primarySwatch: Colors.brown),
        home: const Home(),
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
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
