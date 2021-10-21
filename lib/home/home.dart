import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../board/pedax_board.dart';
import '../board/pedax_shortcuts/pedax_shortcut.dart';
import '../engine/edax_asset.dart';
import '../engine/options/bestpath_count_availability_option.dart';
import '../engine/options/hint_step_by_step_option.dart';
import '../engine/options/level_option.dart';
import '../models/board_notifier.dart';
import '../models/board_state.dart';
import 'bestpath_count_availability_setting_dialog.dart';
import 'book_file_path_setting_dialog.dart';
import 'hint_step_by_step_setting_dialog.dart';
import 'level_setting_dialog.dart';
import 'n_tasks_setting_dialog.dart';
import 'shortcut_cheatsheet_dialog.dart';

@immutable
class Home extends StatefulWidget {
  const Home({final Key? key}) : super(key: key);

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
  double get _movesCountFontSize => _discCountImageSize * 0.4;
  double get _undoOrRedoIconSize => _pedaxBoardBodyLength / 12;

  @override
  void initState() {
    super.initState();
    _setUpEdaxServer(context.read<BoardNotifier>());
  }

  Future<void> _setUpEdaxServer(final BoardNotifier boardNotifier) async {
    await _edaxAsset.setupDllAndData();
    await boardNotifier.spawnEdaxServer(
      libedaxPath: await _edaxAsset.libedaxPath,
      initLibedaxParams: await _edaxAsset.buildInitLibEdaxParams(),
      level: await const LevelOption().val,
      hintStepByStep: await const HintStepByStepOption().val,
      bestpathCountAvailability: await const BestpathCountAvailabilityOption().val,
    );
  }

  @override
  Widget build(final BuildContext context) {
    final edaxServerSpawned = context.select<BoardNotifier, bool>((final notifier) => notifier.value.edaxServerSpawned);
    if (!edaxServerSpawned) return const Center(child: CupertinoActivityIndicator());
    final bookLoadStatus =
        context.select<BoardNotifier, BookLoadStatus?>((final notifier) => notifier.value.bookLoadStatus);
    if (bookLoadStatus == BookLoadStatus.loading) _showSnackBarOfBookLoading();
    if (bookLoadStatus == BookLoadStatus.loaded) _showSnackBarOfBookLoaded();

    return Scaffold(
      appBar: AppBar(
        leading: _menu(),
        title: Text(AppLocalizations.of(context)!.analysisMode),
        centerTitle: true,
        actions: [Image.asset('assets/images/pedax_logo.png', height: kToolbarHeight)],
      ),
      body: context.select<BoardNotifier, bool>((final notifier) => notifier.value.edaxInitOnce)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PedaxBoard(bodyLength: _pedaxBoardBodyLength),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: _pedaxBoardBodyLength / 2, child: _movesCountText),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    SizedBox(width: _pedaxBoardBodyLength / 2, child: _positionInfoText),
                  ],
                ),
                Row(
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
            context.select<BoardNotifier, int>((final notifier) => notifier.value.blackDiscCount).toString(),
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
            context.select<BoardNotifier, int>((final notifier) => notifier.value.whiteDiscCount).toString(),
            style: TextStyle(color: Colors.black, fontSize: _discCountFontSize),
          )
        ],
      );

  void _showSnackBarOfBookLoaded() {
    context.read<BoardNotifier>().finishedNotifyBookHasBeenLoadedToUser();
    WidgetsBinding.instance?.addPostFrameCallback((final _) async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.finishedLoadingBookFile, textAlign: TextAlign.center),
        ),
      );
    });
  }

  void _showSnackBarOfBookLoading() {
    WidgetsBinding.instance?.addPostFrameCallback((final _) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadingBookFile, textAlign: TextAlign.center),
          duration: const Duration(minutes: 1),
        ),
      );
    });
  }

  Text get _positionInfoText {
    final positionFullNum = context.select<BoardNotifier, int>((final notifier) => notifier.value.positionFullNum);
    final data = positionFullNum == 0
        ? AppLocalizations.of(context)!.noPositionInfo
        : AppLocalizations.of(context)!.positionInfo(positionFullNum);
    return Text(
      data,
      style: TextStyle(fontSize: _positionInfoFontSize, fontWeight: FontWeight.bold),
    );
  }

  Text get _movesCountText {
    final movesCount =
        context.select<BoardNotifier, int>((final notifier) => notifier.value.currentMovesCountWithoutPass);
    return Text(
      AppLocalizations.of(context)!.movesCount(movesCount),
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: _movesCountFontSize, fontWeight: FontWeight.bold),
    );
  }

  PopupMenuButton<_Menu> _menu() => PopupMenuButton<_Menu>(
        icon: const Icon(Icons.menu),
        onSelected: (final menu) => menu.onSelected(),
        itemBuilder: (final context) => _sortedMenuList
            .map<PopupMenuItem<_Menu>>(
              (final menu) => PopupMenuItem<_Menu>(
                value: menu,
                child: Text(menu.label),
              ),
            )
            .toList(),
      );

  List<_Menu> get _sortedMenuList => [
        _Menu(
          _MenuType.bookFilePath,
          AppLocalizations.of(context)!.bookFilePathSetting,
          () => showDialog<void>(
            context: context,
            builder: (final _) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: BookFilePathSettingDialog(),
            ),
          ),
        ),
        _Menu(
          _MenuType.level,
          AppLocalizations.of(context)!.levelSetting,
          () => showDialog<void>(
            context: context,
            builder: (final _) => ChangeNotifierProvider.value(
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
            builder: (final _) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: HintStepByStepSettingDialog(),
            ),
          ),
        ),
        _Menu(
          _MenuType.shortcutCheatsheet,
          AppLocalizations.of(context)!.shortcutCheatsheet,
          () => showDialog<void>(
            context: context,
            builder: (final _) => ShortcutCheatsheetDialog(shortcutList: shortcutList(context.read<BoardNotifier>())),
          ),
        ),
        _Menu(
          _MenuType.nTasks,
          AppLocalizations.of(context)!.nTasksSetting,
          () => showDialog<void>(
            context: context,
            builder: (final _) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: NTasksSettingDialog(),
            ),
          ),
        ),
        _Menu(
          _MenuType.bestpathCountAvailability,
          AppLocalizations.of(context)!.bestpathCountAvailabilitySetting,
          () => showDialog<void>(
            context: context,
            builder: (final _) => ChangeNotifierProvider.value(
              value: context.read<BoardNotifier>(),
              child: BestpathCountAvailabilitySettingDialog(),
            ),
          ),
        ),
        _Menu(
          _MenuType.about,
          AppLocalizations.of(context)!.about,
          () => showAboutDialog(
            context: context,
            applicationIcon: Image.asset('assets/images/pedax_logo.png', height: kToolbarHeight),
            // applicationVersion: pacakgeInfo.version // See: https://github.com/flutter/flutter/issues/41728
          ),
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
  bestpathCountAvailability,
  shortcutCheatsheet,
  about,
}
