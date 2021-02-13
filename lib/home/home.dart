import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
import '../board/pedax_board.dart';
import '../engine/edax.dart' show Edax;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<LibEdax> _libedax;

  @override
  void initState() {
    super.initState();
    _libedax = const Edax().initLibedax();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    (await _libedax).libedaxTerminate();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: _menu(), title: _appBarTitle()),
        body: FutureBuilder<LibEdax>(
          future: _libedax,
          builder: (_, snapshot) {
            if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
            return Center(child: PedaxBoard(snapshot.data!, 480));
          },
        ),
      );

  Widget _appBarTitle() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/pedax_logo.png', fit: BoxFit.contain, height: 32),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.homeTitle),
          ),
        ],
      );

  PopupMenuButton<_Menu> _menu() => PopupMenuButton<_Menu>(
        icon: const Icon(Icons.menu),
        onSelected: _onSelectedMenu,
        itemBuilder: (context) => [
          const PopupMenuItem<_Menu>(value: _Menu.license, child: Text('LICENSE')),
        ],
      );

  void Function(_Menu)? _onSelectedMenu(_Menu menu) {
    switch (menu) {
      case _Menu.license:
        showLicensePage(context: context);
    }
  }
}

enum _Menu { license }
