// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:package_info/package_info.dart';
import '../engine/edax.dart' show Edax;

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _edax = Edax();
  Future<String> _boardPrettyString;

  @override
  void initState() {
    super.initState();
    _boardPrettyString = _edax.initLibedax().then(
          (_) async => _edax.lib.edaxGetBoard().prettyString(TurnColor.black),
        );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).homeTitle),
          actions: [
            IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () async {
                  final packageInfo = await PackageInfo.fromPlatform();
                  // ignore: avoid_print
                  print(packageInfo.version);
                })
          ],
        ),
        body: FutureBuilder<String>(
          future: _boardPrettyString,
          builder: (context, snapshot) {
            final text = snapshot.connectionState != ConnectionState.done
                ? 'You have pushed the button this many times:'
                : snapshot.data;
            return Center(
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(text)],
              ),
            );
          },
        ),
      );
}
