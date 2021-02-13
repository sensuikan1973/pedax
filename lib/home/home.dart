import 'dart:io';

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
  final _bookFilePathTextController = TextEditingController();
  final _edax = const Edax();
  late Future<LibEdax> _libedax;

  @override
  void initState() {
    super.initState();
    _libedax = _edax.initLibedax();
  }

  @override
  Future<void> dispose() async {
    _bookFilePathTextController.dispose();
    super.dispose();
    (await _libedax).libedaxTerminate();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: _menu(), title: _appBarTitle()),
        body: FutureBuilder<LibEdax>(
          future: _libedax,
          builder: (_, snapshot) {
            // FIXME: very slow when book is big.
            if (!snapshot.hasData) return const Center(child: Text('initializing engine...'));
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
          PopupMenuItem<_Menu>(
            value: _Menu.bookFilePath,
            child: Text(AppLocalizations.of(context)!.bookFilePathSetting),
          ),
        ],
      );

  Future<void> _onSelectedMenu(_Menu menu) async {
    switch (menu) {
      case _Menu.license:
        showLicensePage(context: context);
        break;
      case _Menu.bookFilePath:
        await _showDialogForSettingBookFilePath();
    }
  }

  Future<void> _showDialogForSettingBookFilePath() async {
    final currentBookFilePath = await _edax.bookPath;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookFilePathSetting),
        content: TextFormField(
          controller: _bookFilePathTextController..text = currentBookFilePath,
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _edax.setBookPath(_bookFilePathTextController.text);
              final libedax = await _libedax;
              // FIXME: very slow when book is big.
              libedax.edaxBookLoad(_bookFilePathTextController.text);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

enum _Menu { license, bookFilePath }
