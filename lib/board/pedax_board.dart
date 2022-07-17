import 'dart:async';

import 'package:flutter/foundation.dart';
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
  PedaxBoard({
    required final this.bodyLength,
    final this.frameWidth = defaultFrameWidth,
    final Color? bodyColor,
    super.key,
  }) : bodyColor = bodyColor ?? Colors.green[900];
  final double bodyLength;
  final double frameWidth;
  final Color? bodyColor;

  static const double defaultFrameWidth = 24;

  @override
  _PedaxBoardState createState() => _PedaxBoardState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('bodyColor', bodyColor))
      ..add(DoubleProperty('bodyLength', bodyLength))
      ..add(DoubleProperty('frameWidth', frameWidth));
  }
}

class _PedaxBoardState extends State<PedaxBoard> {
  final _bookFileOption = const BookFileOption();
  late final BoardNotifier _boardNotifier;
  final List<PedaxShorcut> _shortcutList = shortcutList;
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
    RawKeyboard.instance.addListener(_handleRawKeyEvent);
    Future<void>.delayed(
      const Duration(seconds: 1),
      () async {
        final bookFilePath = await _bookFileOption.val;
        _boardNotifier.requestBookLoad(bookFilePath);
      },
    );
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
              children: [
                _yCoordinateLabels,
                _boardBody,
                _yCoordinateRightFrame,
              ],
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
          children: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
              .map((final x) => Text(x, style: TextStyle(color: _coordinateLabelColor)))
              .toList(),
        ),
      );

  Widget get _xCoordinateBottomFrame => Container(
        width: _lengthWithFrame,
        height: widget.frameWidth,
        color: _frameColor,
      );

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
            (final yIndex) => TableRow(
              children: List.generate(_squareNumPerLine, (final xIndex) => _square(yIndex, xIndex)),
            ),
          ),
        ),
      );

  Future<void> _handleRawKeyEvent(final RawKeyEvent event) async {
    if (!mounted) return;
    final targetEvents = _shortcutList.where((final el) => el.fired(event));
    final targetEvent = targetEvents.isEmpty ? null : targetEvents.first;
    await targetEvent?.runEvent(
      PedaxShortcutEventArguments(
        context.read<BoardNotifier>(),
        _captureKey,
      ),
    );
  }

  Square _square(final int y, final int x) {
    final move = y * 8 + x;
    final type = _squareType(move);
    final moveString = move2String(move);
    final hints = context.select<BoardNotifier, List<Hint>>((final notifier) => notifier.value.hints);
    final targetHints = hints.where((final h) => h.move == move).toList();
    final hint = targetHints.isEmpty ? null : targetHints.first;
    final countBestpathList = context
        .select<BoardNotifier, List<CountBestpathResultWithMove>>((final notifier) => notifier.value.countBestpathList);
    final targetCountBestpathResultWithMove = countBestpathList.where((final el) => el.rootMove == moveString).toList();
    final countBestpathResultWithMove =
        targetCountBestpathResultWithMove.isEmpty ? null : targetCountBestpathResultWithMove.first;
    final lastMove = context.select<BoardNotifier, Move?>((final notifier) => notifier.value.lastMove);
    final bestScore = context.select<BoardNotifier, int>((final notifier) => notifier.value.bestScore);
    final isBookMove = hint != null && hint.isBookMove;
    final level = context.select<BoardNotifier, int>((final notifier) => notifier.value.level);
    final emptyNum = context.select<BoardNotifier, int>((final notifier) => notifier.value.emptyNum);
    final scoreColor = hint == null
        ? null
        : _scoreColor(
            score: hint.score,
            isBookMove: isBookMove,
            isBestMove: hint.score == bestScore,
            // NOTE: with considering edax cache, although depth is not equal to level, if depth is larger than level, regard as completed.
            searchHasCompleted: hint.depth >= level || hint.depth == emptyNum,
          );
    final boardMode = context.select<BoardNotifier, BoardMode>((final notifier) => notifier.value.mode);
    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: moveString,
      isLastMove: lastMove?.x == move,
      isBookMove: isBookMove,
      score: hint?.score,
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
      _boardNotifier.requestSetboard(move);
    }
  }

  SquareType _squareType(final int move) {
    final currentColor = context.select<BoardNotifier, int>((final notifier) => notifier.value.currentColor);
    final squaresOfPlayer =
        context.select<BoardNotifier, List<int>>((final notifier) => notifier.value.squaresOfPlayer);
    final squaresOfOpponent =
        context.select<BoardNotifier, List<int>>((final notifier) => notifier.value.squaresOfOpponent);
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
    required final int? score,
    required final bool isBookMove,
    required final bool isBestMove,
    required final bool searchHasCompleted,
  }) {
    final color = isBestMove ? Colors.lightBlue[200] : Colors.lime;
    if (!searchHasCompleted && !isBookMove) return color?.withOpacity(0.3);
    return color;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoardNotifier>('boardNotifier', _boardNotifier));
  }
}
