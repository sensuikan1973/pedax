// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home/home.dart';

class PedaxApp extends StatelessWidget {
  const PedaxApp({Key key}) : super(key: key);

  // static Widget inProviders({Key key}) => MultiProvider(
  //       providers: [],
  //       child: PedaxApp._(key: key),
  //     );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'pedax',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const HomePage(title: 'pedax title'),
      );
}
