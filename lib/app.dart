import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home/home.dart';

class PedaxApp extends StatelessWidget {
  const PedaxApp({Key? key}) : super(key: key);

  // static Widget inProviders({Key key}) => MultiProvider(
  //       providers: [],
  //       child: PedaxApp._(key: key),
  //     );

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(primarySwatch: Colors.brown),
        home: const HomePage(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('ja', ''), // Japanese, no country code
        ],
      );
}
