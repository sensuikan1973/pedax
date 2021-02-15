import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../board/pedax_board.dart';
import '../engine/edax.dart' show Edax;
import 'book_file_path_setting_dialog.dart';
import 'level_setting_dialog.dart';
import 'n_tasks_setting_dialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _edax = Edax();
  late Future<bool> _libedaxInitialized;

  @override
  void initState() {
    super.initState();
    _libedaxInitialized = _edax.initLibedax();
  }

  @override
  Future<void> dispose() async {
    _edax.lib
      ..libedaxTerminate()
      ..closeDll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: _menu(),
          title: Text(AppLocalizations.of(context)!.homeTitle),
        ),
        body: FutureBuilder<bool>(
          future: _libedaxInitialized,
          builder: (_, snapshot) {
            // FIXME: this is slow when book is big.
            if (!snapshot.hasData) return const Center(child: Text('initializing engine...'));
            return Center(child: PedaxBoard(_edax.lib, 480));
          },
        ),
      );

  PopupMenuButton<_Menu> _menu() => PopupMenuButton<_Menu>(
        icon: const Icon(Icons.menu),
        onSelected: _onSelectedMenu,
        itemBuilder: (context) => [
          PopupMenuItem<_Menu>(
            value: _Menu.bookFilePath,
            child: Text(AppLocalizations.of(context)!.bookFilePathSetting),
          ),
          PopupMenuItem<_Menu>(
            value: _Menu.nTasks,
            child: Text(AppLocalizations.of(context)!.nTasksSetting),
          ),
          PopupMenuItem<_Menu>(
            value: _Menu.level,
            child: Text(AppLocalizations.of(context)!.levelSetting),
          ),
          PopupMenuItem<_Menu>(
            value: _Menu.license,
            child: Text(AppLocalizations.of(context)!.license),
          ),
        ],
      );

  Future<void> _onSelectedMenu(_Menu menu) async {
    switch (menu) {
      case _Menu.bookFilePath:
        await showDialog<void>(context: context, builder: (_) => BookFilePathSettingDialog(edax: _edax));
        break;
      case _Menu.nTasks:
        await showDialog<void>(context: context, builder: (_) => NTasksSettingDialog(edax: _edax));
        break;
      case _Menu.level:
        await showDialog<void>(context: context, builder: (_) => LevelSettingDialog(edax: _edax));
        break;
      case _Menu.license:
        showLicensePage(context: context);
        break;
    }
  }
}

enum _Menu {
  bookFilePath,
  nTasks,
  level,
  license,
}
