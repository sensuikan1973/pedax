import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import '../board/pedax_board.dart';
import '../engine/edax_asset.dart';
import '../engine/edax_server.dart';
import 'book_file_path_setting_dialog.dart';
import 'hint_step_by_step_setting_dialog.dart';
import 'level_setting_dialog.dart';
import 'n_tasks_setting_dialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _edaxAsset = const EdaxAsset();
  final Completer<bool> _edaxServerSpawned = Completer<bool>();
  late final SendPort _edaxServerPort;
  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _spawnEdaxServer();
  }

  Future<void> _spawnEdaxServer() async {
    await _edaxAsset.setupDllAndData();
    final initLibedaxParameters = await _edaxAsset.buildInitLibEdaxParams();
    await Isolate.spawn(
      startEdaxServer,
      StartEdaxServerParams(_receivePort.sendPort, await _edaxAsset.libedaxPath, initLibedaxParameters),
    );
    _receiveStream = _receivePort.asBroadcastStream();
    _edaxServerPort = await _receiveStream.first as SendPort;
    setState(() {
      _edaxServerSpawned.complete(true);
      _logger.d('spawned edax server');
    });
  }

  @override
  void dispose() {
    _receivePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: _menu(),
          title: Text(AppLocalizations.of(context)!.analysisMode),
        ),
        body: FutureBuilder<bool>(
          future: _edaxServerSpawned.future,
          builder: (_, snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return Center(
                child: PedaxBoard(_edaxServerPort, _receiveStream, 480),
              );
            }
            return const Center(child: Text('initializing engine...'));
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
          () => showDialog<void>(
            context: context,
            builder: (_) => BookFilePathSettingDialog(edaxServerPort: _edaxServerPort),
          ),
        ),
        _Menu(
          _MenuType.nTasks,
          AppLocalizations.of(context)!.nTasksSetting,
          () => showDialog<void>(
            context: context,
            builder: (_) => NTasksSettingDialog(edaxServerPort: _edaxServerPort),
          ),
        ),
        _Menu(
          _MenuType.level,
          AppLocalizations.of(context)!.levelSetting,
          () => showDialog<void>(
            context: context,
            builder: (_) => LevelSettingDialog(edaxServerPort: _edaxServerPort),
          ),
        ),
        _Menu(
          _MenuType.hintStepByStep,
          AppLocalizations.of(context)!.hintStepByStepSetting,
          () => showDialog<void>(
            context: context,
            builder: (_) => const HintStepByStepSettingDialog(),
          ),
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
  hintStepByStep,
  license,
}
