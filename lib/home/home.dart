import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
import '../board/pedax_board.dart';
import '../engine/edax.dart' show Edax;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _edax = const Edax();
  late Future<LibEdax> _libedax;

  @override
  void initState() {
    super.initState();
    _libedax = _edax.initLibedax();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    (await _libedax)
      ..libedaxTerminate()
      ..closeDll();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: _menu(), title: _appBarTitle()),
        body: FutureBuilder<LibEdax>(
          future: _libedax,
          builder: (_, snapshot) {
            // FIXME: this is slow when book is big.
            if (!snapshot.hasData) return const Center(child: Text('initializing engine...'));
            return Center(child: PedaxBoard(snapshot.data!, 480));
          },
        ),
      );

  Widget _appBarTitle() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: remove this. logo should be shown as app icon.
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
          PopupMenuItem<_Menu>(
            value: _Menu.license,
            child: Text(AppLocalizations.of(context)!.license),
          ),
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
    final bookFilePathTextController = TextEditingController();
    final bookFilePathFormKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookFilePathSetting),
        content: Form(
          key: bookFilePathFormKey,
          child: TextFormField(
            controller: bookFilePathTextController..text = currentBookFilePath,
            autofocus: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (path) {
              if (path == null) return null;
              if (path.isEmpty) return null; // use default book
              if (!File(path).existsSync()) return AppLocalizations.of(context)!.userSpecifiedFileNotFound;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelOnDialog),
          ),
          TextButton(
            onPressed: () async {
              if (!bookFilePathFormKey.currentState!.validate()) return;
              final currentBookPath = await _edax.bookPath;
              final newBookPath = bookFilePathTextController.text;
              await _edax.setBookPath(newBookPath);
              if (currentBookPath != newBookPath) {
                // TODO: load asynchronously. this is slow when book is big.
                (await _libedax).edaxBookLoad(newBookPath);
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.updateSettingOnDialog),
          ),
        ],
      ),
    );
  }
}

enum _Menu { license, bookFilePath }
