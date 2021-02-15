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
          title: Text(AppLocalizations.of(context)!.analysisMode),
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
        onSelected: (menu) => menu.onSelected(),
        itemBuilder: (context) => _sortedMenuList
            .map<PopupMenuItem<_Menu>>((menu) => PopupMenuItem<_Menu>(
                  value: menu,
                  child: Text(menu.label),
                ))
            .toList(),
      );

  List<_Menu> get _sortedMenuList => [
        _Menu(
          _MenuType.bookFilePath,
          AppLocalizations.of(context)!.bookFilePathSetting,
          () async => showDialog<void>(context: context, builder: (_) => BookFilePathSettingDialog(edax: _edax)),
        ),
        _Menu(
          _MenuType.nTasks,
          AppLocalizations.of(context)!.nTasksSetting,
          () async => showDialog<void>(context: context, builder: (_) => NTasksSettingDialog(edax: _edax)),
        ),
        _Menu(
          _MenuType.level,
          AppLocalizations.of(context)!.levelSetting,
          () async => showDialog<void>(context: context, builder: (_) => LevelSettingDialog(edax: _edax)),
        ),
        _Menu(
          _MenuType.license,
          AppLocalizations.of(context)!.license,
          () => showLicensePage(context: context),
        ),
      ];
}

@immutable
class _Menu {
  const _Menu(this.type, this.label, this.onSelected);
  final _MenuType type;
  final String label;
  final Function() onSelected;
}

enum _MenuType {
  bookFilePath,
  nTasks,
  level,
  license,
}
