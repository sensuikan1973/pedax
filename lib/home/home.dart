import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../board/pedax_board.dart';
import '../board/pedax_shortcuts/pedax_shortcut.dart';
import '../engine/edax_asset.dart';
import '../engine/options/hint_step_by_step_option.dart';
import '../engine/options/level_option.dart';
import '../models/board_notifier.dart';
import '../models/board_state.dart';
import 'book_file_path_setting_dialog.dart';
import 'hint_step_by_step_setting_dialog.dart';
import 'level_setting_dialog.dart';
import 'n_tasks_setting_dialog.dart';
import 'shortcut_cheatsheet_dialog.dart';

@immutable
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _edaxAsset = const EdaxAsset();
  double get _pedaxBoardBodyLength => min(
        MediaQuery.of(context).size.width * 0.8,
        MediaQuery.of(context).size.height * 0.7,
      );
  double get _discCountImageSize => _pedaxBoardBodyLength / 12;
  double get _discCountFontSize => _discCountImageSize * 0.4;
  double get _positionInfoFontSize => _discCountImageSize * 0.4;
  double get _undoOrRedoIconSize => _pedaxBoardBodyLength / 12;

  @override
  void initState() {
    super.initState();
    _setUpEdaxServer();
  }

  Future<void> _setUpEdaxServer() async {
    await _edaxAsset.setupDllAndData();
    final boardNotifier = context.read<BoardNotifier>();
    await boardNotifier.spawnEdaxServer(
      libedaxPath: await _edaxAsset.libedaxPath,
      initLibedaxParams: await _edaxAsset.buildInitLibEdaxParams(),
      level: await const LevelOption().val,
      hintStepByStep: await const HintStepByStepOption().val,
    );
  }

  @override
  Widget build(BuildContext context) {
    final edaxInitOnce = context.select<BoardNotifier, bool>((notifier) => notifier.value.edaxInitOnce);
    if (!edaxInitOnce) return const Center(child: CupertinoActivityIndicator());
    final bookLoadStatus = context.select<BoardNotifier, BookLoadStatus>((notifier) => notifier.value.bookLoadStatus);
    if (bookLoadStatus == BookLoadStatus.loaded) _showSnackBarOfBookLoaded();
    if (bookLoadStatus == BookLoadStatus.loading) _showSnackBarOfBookLoading();

    return Scaffold(
      appBar: AppBar(
        leading: _menu(),
        title: Text(AppLocalizations.of(context)!.analysisMode, textAlign: TextAlign.center),
      ),
      body: context.select<BoardNotifier, bool>((notifier) => notifier.value.edaxServerSpawned)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(_positionInfoText, style: TextStyle(fontSize: _positionInfoFontSize)),
                ),
                PedaxBoard(bodyLength: _pedaxBoardBodyLength),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _undoAllButton,
                      _undoButton,
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                      _blackDiscCount,
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                      _whiteDiscCount,
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                      _redoButton,
                      _redoAllButton,
                    ],
                  ),
                ),
              ],
            )
          : Center(child: Text(AppLocalizations.of(context)!.initializingEngine)),
    );
  }

  Widget get _undoAllButton => IconButton(
        icon: const Icon(FontAwesomeIcons.angleDoubleLeft),
        iconSize: _undoOrRedoIconSize,
        onPressed: () => context.read<BoardNotifier>().requestUndoAll(),
      );

  Widget get _undoButton => IconButton(
        icon: const Icon(FontAwesomeIcons.angleLeft),
        iconSize: _undoOrRedoIconSize,
        onPressed: () => context.read<BoardNotifier>().requestUndo(),
      );

  Widget get _redoButton => IconButton(
        icon: const Icon(FontAwesomeIcons.angleRight),
        iconSize: _undoOrRedoIconSize,
        onPressed: () => context.read<BoardNotifier>().requestRedo(),
      );

  Widget get _redoAllButton => IconButton(
        icon: const Icon(FontAwesomeIcons.angleDoubleRight),
        iconSize: _undoOrRedoIconSize,
        onPressed: () => context.read<BoardNotifier>().requestRedoAll(),
      );

  Widget get _blackDiscCount => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _discCountImageSize,
            height: _discCountImageSize,
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          ),
          Text(
            context.select<BoardNotifier, int>((notifier) => notifier.value.blackDiscCount).toString(),
            style: TextStyle(color: Colors.white, fontSize: _discCountFontSize),
          )
        ],
      );

  Widget get _whiteDiscCount => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _discCountImageSize,
            height: _discCountImageSize,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all()),
          ),
          Text(
            context.select<BoardNotifier, int>((notifier) => notifier.value.whiteDiscCount).toString(),
            style: TextStyle(color: Colors.black, fontSize: _discCountFontSize),
          )
        ],
      );

  void _showSnackBarOfBookLoaded() {
    context.read<BoardNotifier>().value.bookLoadStatus = BookLoadStatus.notifiedToUser;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.finishedLoadingBookFile, textAlign: TextAlign.center),
        ),
      );
    });
  }

  void _showSnackBarOfBookLoading() {
    context.read<BoardNotifier>().value.bookLoadStatus = BookLoadStatus.notifiedToUser;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadingBookFile, textAlign: TextAlign.center),
          duration: const Duration(minutes: 1),
        ),
      );
    });
  }

  String get _positionInfoText {
    final positionFullNum = context.select<BoardNotifier, int>((notifier) => notifier.value.positionFullNum);
    return positionFullNum == 0
        ? AppLocalizations.of(context)!.noPositionInfo
        : AppLocalizations.of(context)!.positionInfo(
            positionFullNum,
            context.select<BoardNotifier, int>((notifier) => notifier.value.positionWinsRate),
            context.select<BoardNotifier, int>((notifier) => notifier.value.positionDrawsRate),
          );
  }

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
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: BookFilePathSettingDialog(),
            ),
          ),
        ),
        _Menu(
          _MenuType.nTasks,
          AppLocalizations.of(context)!.nTasksSetting,
          () => showDialog<void>(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: NTasksSettingDialog(),
            ),
          ),
        ),
        _Menu(
          _MenuType.level,
          AppLocalizations.of(context)!.levelSetting,
          () => showDialog<void>(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: LevelSettingDialog(),
            ),
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
          _MenuType.shortcutCheatsheet,
          AppLocalizations.of(context)!.shortcutCheatsheet,
          () => showDialog<void>(
            context: context,
            builder: (_) => ShortcutCheatsheetDialog(shortcutList: shortcutList(context.read<BoardNotifier>())),
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
  shortcutCheatsheet,
  license,
}
