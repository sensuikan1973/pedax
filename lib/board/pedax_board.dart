import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:provider/provider.dart';

import '../engine/options/native/book_file_option.dart';
import '../models/board_notifier.dart';
import '../models/board_state.dart';
import 'pedax_shortcuts/pedax_shortcut.dart';
import 'square.dart';

@immutable
class PedaxBoard extends StatefulWidget {
  PedaxBoard({required this.bodyLength, this.frameWidth = defaultFrameWidth, final Color? bodyColor, super.key})
    : bodyColor = bodyColor ?? Colors.green[900];
  final double bodyLength;
  final double frameWidth;
  final Color? bodyColor;

  static const double defaultFrameWidth = 24;

  @override
  PedaxBoardState createState() => PedaxBoardState();
}

class PedaxBoardState extends State<PedaxBoard> {
  final _bookFileOption = BookFileOption();
  late final BoardNotifier _boardNotifier;
  int get _squareNumPerLine => 8;
  double get _stoneMargin => (widget.bodyLength / _squareNumPerLine) * 0.1;
  double get _stoneSize => (widget.bodyLength / _squareNumPerLine) - (_stoneMargin * 2);
  Color get _coordinateLabelColor => Colors.white54;
  Color get _frameColor => Colors.black;
  double get _lengthWithFrame => widget.bodyLength + widget.frameWidth * 2;
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _boardNotifier = context.read<BoardNotifier>()..requestInit();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    Future<void>.delayed(Duration.zero, () async {
      final bookFilePath = await _bookFileOption.val;
      _boardNotifier.requestBookLoad(bookFilePath);
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => RepaintBoundary(
    key: _captureKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _lengthWithFrame,
          color: _frameColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: widget.frameWidth, width: widget.frameWidth),
              _xCoordinateLabels,
              SizedBox(height: widget.frameWidth, width: widget.frameWidth),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_yCoordinateLabels, _boardBody, _yCoordinateRightFrame],
        ),
        _xCoordinateBottomFrame,
      ],
    ),
  );

  Widget get _xCoordinateLabels => Container(
    color: _frameColor,
    width: widget.bodyLength,
    height: widget.frameWidth,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          [
            'a',
            'b',
            'c',
            'd',
            'e',
            'f',
            'g',
            'h',
          ].map((final x) => Text(x, style: TextStyle(color: _coordinateLabelColor))).toList(),
    ),
  );

  Widget get _xCoordinateBottomFrame =>
      Container(width: _lengthWithFrame, height: widget.frameWidth, color: _frameColor);

  Widget get _yCoordinateLabels => Container(
    color: _frameColor,
    height: widget.bodyLength,
    width: widget.frameWidth,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        _squareNumPerLine,
        (final i) => Text((i + 1).toString(), style: TextStyle(color: _coordinateLabelColor)),
      ),
    ),
  );

  Widget get _yCoordinateRightFrame =>
      Container(color: _frameColor, height: widget.bodyLength, width: widget.frameWidth);

  Widget get _boardBody => Container(
    color: widget.bodyColor,
    height: widget.bodyLength,
    width: widget.bodyLength,
    child: Table(
      border: TableBorder.all(),
      children: List.generate(
        _squareNumPerLine,
        (final yIndex) =>
            TableRow(children: List.generate(_squareNumPerLine, (final xIndex) => _square(yIndex, xIndex))),
      ),
    ),
  );

  bool _handleKeyEvent(final KeyEvent event) {
    if (!mounted) return false;
    final targetEvents = shortcutList.where((final el) => el.fired(event));
    final targetEvent = targetEvents.isEmpty ? null : targetEvents.first;
    targetEvent?.runEvent(PedaxShortcutEventArguments(context.read<BoardNotifier>(), _captureKey));
    return false;
  }

  Square _square(final int y, final int x) {
    final move = y * 8 + x;
    final type = _squareType(move);
    final moveString = move2String(move);
    final hintsWithStepByStep = context.select<BoardNotifier, List<HintWithStepByStep>>(
      (final notifier) => notifier.value.hintsWithStepByStep,
    );
    final targetHints = hintsWithStepByStep.where((final el) => el.hint.move == move).toList();
    final hintWithStepByStep = targetHints.isEmpty ? null : targetHints.first;
    final countBestpathList = context.select<BoardNotifier, List<CountBestpathResultWithMove>>(
      (final notifier) => notifier.value.countBestpathList,
    );
    final targetCountBestpathResultWithMove = countBestpathList.where((final el) => el.rootMove == moveString).toList();
    final countBestpathResultWithMove =
        targetCountBestpathResultWithMove.isEmpty ? null : targetCountBestpathResultWithMove.first;
    final lastMove = context.select<BoardNotifier, Move?>((final notifier) => notifier.value.lastMove);
    final bestScore = context.select<BoardNotifier, int>((final notifier) => notifier.value.bestScore);
    final isBookMove = hintWithStepByStep != null && hintWithStepByStep.hint.isBookMove;
    final scoreColor =
        hintWithStepByStep == null
            ? null
            : _scoreColor(
              isBookMove: isBookMove,
              isBestMove: hintWithStepByStep.hint.score == bestScore,
              searchHasCompleted: hintWithStepByStep.isLastStep,
            );
    final boardMode = context.select<BoardNotifier, BoardMode>((final notifier) => notifier.value.mode);
    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: moveString,
      isLastMove: lastMove?.x == move,
      isBookMove: isBookMove,
      score: hintWithStepByStep?.hint.score,
      bestpathCountOfBlack: _bestpathCount(TurnColor.black, countBestpathResultWithMove),
      bestpathCountOfWhite: _bestpathCount(TurnColor.white, countBestpathResultWithMove),
      scoreColor: scoreColor,
      onTap: () => _squareOnTap(boardMode, type, move),
    );
  }

  void _squareOnTap(final BoardMode boardMode, final SquareType type, final int move) {
    if (boardMode == BoardMode.freePlay && type == SquareType.empty) {
      _boardNotifier.requestMove(move2String(move));
    } else if (boardMode == BoardMode.arrangeDiscs) {
      _boardNotifier.requestSetboard([move]);
    }
  }

  SquareType _squareType(final int move) {
    final currentColor = context.select<BoardNotifier, int>((final notifier) => notifier.value.currentColor);
    final squaresOfPlayer = context.select<BoardNotifier, List<int>>(
      (final notifier) => notifier.value.squaresOfPlayer,
    );
    final squaresOfOpponent = context.select<BoardNotifier, List<int>>(
      (final notifier) => notifier.value.squaresOfOpponent,
    );
    final isBlackTurn = currentColor == TurnColor.black;
    if (squaresOfPlayer.contains(move)) {
      return isBlackTurn ? SquareType.black : SquareType.white;
    } else if (squaresOfOpponent.contains(move)) {
      return isBlackTurn ? SquareType.white : SquareType.black;
    } else {
      return SquareType.empty;
    }
  }

  int? _bestpathCount(final int color, final CountBestpathResultWithMove? countBestpathResultWithMove) {
    if (countBestpathResultWithMove == null) return null;
    final currentColor = context.select<BoardNotifier, int>((final notifier) => notifier.value.currentColor);
    final isYourTurn = currentColor == color;

    /// NOTE:
    /// Why "when isYourTurn == true, show opponent value" ?
    /// -> See: [CountBestpathResponse] class in lib/engine/api/count_bestpath.dart.
    return isYourTurn
        ? countBestpathResultWithMove.countBestpathList.position.nOpponentBestpaths
        : countBestpathResultWithMove.countBestpathList.position.nPlayerBestpaths;
  }

  Color? _scoreColor({
    required final bool isBookMove,
    required final bool isBestMove,
    required final bool searchHasCompleted,
  }) {
    final color = isBestMove ? Colors.lightBlue[200] : Colors.lime;
    if (!searchHasCompleted && !isBookMove) return color?.withValues(alpha: 0.3);
    return color;
  }
}
