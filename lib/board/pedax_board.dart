import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:provider/provider.dart';

import '../engine/options/book_file_option.dart';
import '../models/board_notifier.dart';
import 'square.dart';

@immutable
class PedaxBoard extends StatefulWidget {
  const PedaxBoard(this.length, {Key? key}) : super(key: key);
  final double length;

  @override
  _PedaxBoardState createState() => _PedaxBoardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('length', length));
  }
}

class _PedaxBoardState extends State<PedaxBoard> {
  late final BoardNotifier boardNotifier;
  int get _boardSize => 8;
  double get _stoneMargin => (widget.length / _boardSize) * 0.1;
  double get _stoneSize => (widget.length / _boardSize) - (_stoneMargin * 2);

  @override
  void initState() {
    super.initState();
    boardNotifier = context.read<BoardNotifier>();
    boardNotifier.requestInit();
    const BookFileOption().val.then((bookFilePath) {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loadingBookFile, textAlign: TextAlign.center),
            duration: const Duration(minutes: 1),
          ),
        );
      });
      boardNotifier.requestBookLoad(bookFilePath);
    });
    RawKeyboard.instance.addListener(_handleRawKeyEvent);
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _xCoordinateLabels,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _yCoordinateLabels,
              _boardBody,
              _yCoordinatePadding,
            ],
          ),
        ],
      );

  Widget get _xCoordinateLabels => SizedBox(
        width: widget.length / _boardSize * 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', ' ']
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(e),
                  ))
              .toList(),
        ),
      );

  Widget get _yCoordinateLabels => SizedBox(
        height: widget.length,
        width: widget.length / _boardSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            _boardSize,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text((i + 1).toString()),
            ),
          ),
        ),
      );

  Widget get _yCoordinatePadding => SizedBox(height: widget.length, width: widget.length / _boardSize);

  Widget get _boardBody => Container(
        color: Colors.green[900],
        height: widget.length,
        width: widget.length,
        child: Table(
          border: TableBorder.all(),
          children: List.generate(
            _boardSize,
            (yIndex) => TableRow(
              children: List.generate(_boardSize, (xIndex) => _square(yIndex, xIndex)),
            ),
          ),
        ),
      );

  Future<void> _handleRawKeyEvent(RawKeyEvent event) async {
    if (event.isKeyPressed(LogicalKeyboardKey.keyU)) boardNotifier.requestUndo();
    if (event.isKeyPressed(LogicalKeyboardKey.keyR)) boardNotifier.requestRedo();
    if (event.isKeyPressed(LogicalKeyboardKey.keyS)) boardNotifier.requestUndoAll();
    if (event.isKeyPressed(LogicalKeyboardKey.keyE)) boardNotifier.requestRedoAll();
    if (event.isKeyPressed(LogicalKeyboardKey.keyH)) await boardNotifier.switchHintVisibility();
    if ((event.isControlPressed && event.isKeyPressed(LogicalKeyboardKey.keyC)) ||
        (event.data.isModifierPressed(ModifierKey.metaModifier) && event.isKeyPressed(LogicalKeyboardKey.keyC))) {
      await Clipboard.setData(ClipboardData(text: boardNotifier.value.currentMoves));
    }
    if ((event.isControlPressed && event.isKeyPressed(LogicalKeyboardKey.keyV)) ||
        (event.data.isModifierPressed(ModifierKey.metaModifier) && event.isKeyPressed(LogicalKeyboardKey.keyV))) {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData == null || clipboardData.text == null) return;
      boardNotifier.requestPlay(clipboardData.text!);
    }
  }

  Square _square(int y, int x) {
    final move = y * 8 + x;
    final type = _squareType(move);
    final moveString = move2String(move);
    final hints = context.select<BoardNotifier, List<Hint>>((notifier) => notifier.value.hints);
    final targetHints = hints.where((h) => h.move == move).toList();
    final hint = targetHints.isEmpty ? null : targetHints.first;
    final lastMove = context.select<BoardNotifier, Move?>((notifier) => notifier.value.lastMove);
    final bestScore = context.select<BoardNotifier, int>((notifier) => notifier.value.bestScore);
    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: moveString,
      isLastMove: lastMove?.x == move,
      isBookMove: hint != null && hint.isBookMove,
      score: hint?.score,
      scoreColor: _scoreColor(hint?.score, hint?.score == bestScore),
      onTap: type != SquareType.empty ? null : () => _squareOnTap(moveString),
    );
  }

  void _squareOnTap(String moveString) {
    boardNotifier.requestMove(moveString);
  }

  SquareType _squareType(int move) {
    final currentColor = context.select<BoardNotifier, int>((notifier) => notifier.value.currentColor);
    final squaresOfPlayer = context.select<BoardNotifier, List<int>>((notifier) => notifier.value.squaresOfPlayer);
    final squaresOfOpponent = context.select<BoardNotifier, List<int>>((notifier) => notifier.value.squaresOfOpponent);
    final isBlackTurn = currentColor == TurnColor.black;
    if (squaresOfPlayer.contains(move)) {
      return isBlackTurn ? SquareType.black : SquareType.white;
    }
    if (squaresOfOpponent.contains(move)) {
      return isBlackTurn ? SquareType.white : SquareType.black;
    }
    return SquareType.empty;
  }

  Color? _scoreColor(int? score, bool bestMove) {
    if (score == null) return null;
    if (score >= 0) {
      if (bestMove) return Colors.lightBlue[200];
      return Colors.blue[600];
    } else /* score < 0*/ {
      if (bestMove) return Colors.lime;
      return Colors.lime[900];
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoardNotifier>('notifier', boardNotifier));
  }
}
