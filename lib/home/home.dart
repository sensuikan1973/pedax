// @dart = 2.11
// See: https://github.com/flutter/plugins/pull/3330 (path_provider)
// See: https://github.com/flutter/plugins/pull/3466 (shared_preferences)
// See: https://dart.dev/null-safety/unsound-null-safety

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/pedax_logo.png', fit: BoxFit.contain, height: 32),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(AppLocalizations.of(context).homeTitle),
              ),
            ],
          ),
        ),
        body: FutureBuilder<String>(
          future: _boardPrettyString,
          builder: (_, snapshot) {
            final text = snapshot.connectionState != ConnectionState.done ? 'initializing libedax...' : snapshot.data;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(text)],
              ),
            );
          },
        ),
      );
}
