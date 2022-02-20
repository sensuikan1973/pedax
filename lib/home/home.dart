import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:provider/provider.dart';

import '../board/pedax_board.dart';
import '../board/pedax_shortcuts/pedax_shortcut.dart';
import '../engine/edax_asset.dart';
import '../engine/options/native/level_option.dart';
import '../engine/options/pedax/bestpath_count_availability_option.dart';
import '../engine/options/pedax/hint_step_by_step_option.dart';
import '../models/board_notifier.dart';
import '../models/board_state.dart';
import 'setting_dialogs/bestpath_count_availability_setting_dialog.dart';
import 'setting_dialogs/book_file_path_setting_dialog.dart';
import 'setting_dialogs/hint_step_by_step_setting_dialog.dart';
import 'setting_dialogs/level_setting_dialog.dart';
import 'setting_dialogs/n_tasks_setting_dialog.dart';
import 'setting_dialogs/shortcut_cheatsheet_dialog.dart';

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
  double get _arrangeTargetStoneSize => _discCountImageSize;
  Color get _currentColorBorderColor => Colors.pink;
  double get _currentColorBoardWidth => 2;
  Color? get _boardBodyColor => Colors.green[900];

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
      appBar: _appBar,
      body: context.select<BoardNotifier, bool>((final notifier) => notifier.value.edaxInitOnce)
          ? _body
          : Center(child: Text(AppLocalizations.of(context)!.initializingEngine)),
    );
  }

  Widget get _body => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PedaxBoard(bodyLength: _pedaxBoardBodyLength, bodyColor: _boardBodyColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: _pedaxBoardBodyLength / 2, child: _movesCountText),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
              SizedBox(width: _pedaxBoardBodyLength / 2, child: _positionInfoText),
            ],
          ),
          _bottomItems,
        ],
      );

  Widget get _bottomItems {
    final boardMode = context.select<BoardNotifier, BoardMode>((final notifier) => notifier.value.mode);
    if (boardMode == BoardMode.arrangeDiscs) return _arrangeTargetSelection;
    return _freePlayOperationItems;
  }

  Widget get _freePlayOperationItems => Row(
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
      );

  Widget get _arrangeTargetSelection {
    final currentArrangeTargetSquareType =
        context.select<BoardNotifier, ArrangeTargetType>((final notifier) => notifier.value.arrangeTargetSquareType);
    final selectedMark = Border.all(color: Colors.red, width: 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          key: const Key('switchArrangeTargetToBlack'),
          onTap: () => context.read<BoardNotifier>().switchArrangeTarget(ArrangeTargetType.black),
          child: Container(
            width: _arrangeTargetStoneSize,
            height: _arrangeTargetStoneSize,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: currentArrangeTargetSquareType == ArrangeTargetType.black ? selectedMark : null,
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        GestureDetector(
          key: const Key('switchArrangeTargetToWhite'),
          onTap: () => context.read<BoardNotifier>().switchArrangeTarget(ArrangeTargetType.white),
          child: Container(
            width: _arrangeTargetStoneSize,
            height: _arrangeTargetStoneSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: currentArrangeTargetSquareType == ArrangeTargetType.white ? selectedMark : Border.all(),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        GestureDetector(
          key: const Key('switchArrangeTargetToEmpty'),
          onTap: () => context.read<BoardNotifier>().switchArrangeTarget(ArrangeTargetType.empty),
          child: Container(
            width: _arrangeTargetStoneSize,
            height: _arrangeTargetStoneSize,
            decoration: BoxDecoration(
              color: _boardBodyColor,
              border: currentArrangeTargetSquareType == ArrangeTargetType.empty ? selectedMark : null,
            ),
          ),
        ),
      ],
    );
  }

  AppBar get _appBar {
    final boardMode = context.select<BoardNotifier, BoardMode>((final notifier) => notifier.value.mode);
    return AppBar(
      leading: _menu(),
      title: PopupMenuButton<BoardMode>(
        initialValue: boardMode,
        tooltip: AppLocalizations.of(context)!.modeSelectionTooltip,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
          child: Text(_boardModeString(boardMode)),
        ),
        onSelected: (final boardMode) => context.read<BoardNotifier>().switchBoardMode(boardMode),
        itemBuilder: (final context) => BoardMode.values
            .map(
              (final mode) => PopupMenuItem<BoardMode>(
                value: mode,
                child: Text(_boardModeString(mode)),
              ),
            )
            .toList(),
      ),
      centerTitle: true,
      actions: [Image.asset('assets/images/pedax_logo.png', height: kToolbarHeight)],
    );
  }

  String _boardModeString(final BoardMode boardMode) {
    switch (boardMode) {
      case BoardMode.freePlay:
        return AppLocalizations.of(context)!.freePlayMode;
      case BoardMode.arrangeDiscs:
        return AppLocalizations.of(context)!.arrangeDiscsMode;
    }
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

  Widget get _blackDiscCount {
    final currentColor = context.select<BoardNotifier, int>((final notifier) => notifier.value.currentColor);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: _discCountImageSize,
          height: _discCountImageSize,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: currentColor == TurnColor.black
                ? Border.all(color: _currentColorBorderColor, width: _currentColorBoardWidth)
                : null,
          ),
        ),
        Text(
          context.select<BoardNotifier, int>((final notifier) => notifier.value.blackDiscCount).toString(),
          style: TextStyle(color: Colors.white, fontSize: _discCountFontSize),
        )
      ],
    );
  }

  Widget get _whiteDiscCount {
    final currentColor = context.select<BoardNotifier, int>((final notifier) => notifier.value.currentColor);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: _discCountImageSize,
          height: _discCountImageSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: currentColor == TurnColor.white
                ? Border.all(color: _currentColorBorderColor, width: _currentColorBoardWidth)
                : Border.all(),
          ),
        ),
        Text(
          context.select<BoardNotifier, int>((final notifier) => notifier.value.whiteDiscCount).toString(),
          style: TextStyle(color: Colors.black, fontSize: _discCountFontSize),
        )
      ],
    );
  }

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
          _MenuType.shortcutCheatsheet,
          AppLocalizations.of(context)!.shortcutCheatsheet,
          () => showDialog<void>(
            context: context,
            builder: (final _) => ShortcutCheatsheetDialog(shortcutList: shortcutList(context.read<BoardNotifier>())),
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
