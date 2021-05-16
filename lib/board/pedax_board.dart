import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:provider/provider.dart';

import '../engine/options/book_file_option.dart';
import '../models/board_notifier.dart';
import 'pedax_shortcuts/pedax_shortcut.dart';
import 'square.dart';

@immutable
class PedaxBoard extends StatefulWidget {
  const PedaxBoard({required this.bodyLength, this.frameWidth = defaultFrameWidth, Key? key}) : super(key: key);
  final double bodyLength;
  final double frameWidth;

  static const double defaultFrameWidth = 24;

  @override
  _PedaxBoardState createState() => _PedaxBoardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DoubleProperty('bodyLength', bodyLength))..add(DoubleProperty('frameWidth', frameWidth));
  }
}

class _PedaxBoardState extends State<PedaxBoard> {
  final _bookFileOption = const BookFileOption();
  late final BoardNotifier _boardNotifier;
  late final List<PedaxShorcut> _shortcutList;
  int get _squareNumPerLine => 8;
  double get _stoneMargin => (widget.bodyLength / _squareNumPerLine) * 0.1;
  double get _stoneSize => (widget.bodyLength / _squareNumPerLine) - (_stoneMargin * 2);
  Color get _coordinateLabelColor => Colors.white54;
  Color get _frameColor => Colors.black;
  double get _lengthWithFrame => widget.bodyLength + widget.frameWidth * 2;

  @override
  void initState() {
    super.initState();
    _boardNotifier = context.read<BoardNotifier>()..requestInit();
    _shortcutList = shortcutList(_boardNotifier);
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
  Widget build(BuildContext context) => Column(
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
              _yCoordinateRightPadding,
            ],
          ),
          _xCoordinateBottomPadding,
        ],
      );

  Widget get _xCoordinateLabels => Container(
        color: _frameColor,
        width: widget.bodyLength,
        height: widget.frameWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
              .map((x) => Text(x, style: TextStyle(color: _coordinateLabelColor)))
              .toList(),
        ),
      );

  Widget get _xCoordinateBottomPadding => Container(
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
            (i) => Text((i + 1).toString(), style: TextStyle(color: _coordinateLabelColor)),
          ),
        ),
      );

  Widget get _yCoordinateRightPadding =>
      Container(color: _frameColor, height: widget.bodyLength, width: widget.frameWidth);

  Widget get _boardBody => Container(
        color: Colors.green[900],
        height: widget.bodyLength,
        width: widget.bodyLength,
        child: Table(
          border: TableBorder.all(),
          children: List.generate(
            _squareNumPerLine,
            (yIndex) => TableRow(
              children: List.generate(_squareNumPerLine, (xIndex) => _square(yIndex, xIndex)),
            ),
          ),
        ),
      );

  Future<void> _handleRawKeyEvent(RawKeyEvent event) async {
    final targetEvents = _shortcutList.where((el) => el.fired(event));
    final targetEvent = targetEvents.isEmpty ? null : targetEvents.first;
    await targetEvent?.runEvent();
  }

  Square _square(int y, int x) {
    final move = y * 8 + x;
    final type = _squareType(move);
    final moveString = move2String(move);
    final hints = context.select<BoardNotifier, List<Hint>>((notifier) => notifier.value.hints);
    final targetHints = hints.where((h) => h.move == move).toList();
    final hint = targetHints.isEmpty ? null : targetHints.first;
    final bestPathNumList =
        context.select<BoardNotifier, List<BestPathNumWithLink>>((notifier) => notifier.value.bestPathNumList);
    final targetBestPathNum = bestPathNumList.where((b) => b.move == move).toList();
    final bestPathNum = targetBestPathNum.isEmpty ? null : targetBestPathNum.first;
    final lastMove = context.select<BoardNotifier, Move?>((notifier) => notifier.value.lastMove);
    final bestScore = context.select<BoardNotifier, int>((notifier) => notifier.value.bestScore);
    final isBookMove = hint != null && hint.isBookMove;
    final level = context.select<BoardNotifier, int>((notifier) => notifier.value.level);
    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: moveString,
      isLastMove: lastMove?.x == move,
      isBookMove: isBookMove,
      score: hint?.score,
      bestPathNumOfBlack: bestPathNum?.bestPathNumOfBlack,
      bestPathNumOfWhite: bestPathNum?.bestPathNumOfWhite,
      scoreColor: _scoreColor(
        score: hint?.score,
        isBookMove: isBookMove,
        isBestMove: hint?.score == bestScore,
        searchHasCompleted: hint != null && hint.depth == level,
      ),
      onTap: type != SquareType.empty ? null : () => _squareOnTap(moveString),
    );
  }

  void _squareOnTap(String moveString) {
    _boardNotifier.requestMove(moveString);
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

  Color? _scoreColor({
    required int? score,
    required bool isBookMove,
    required bool isBestMove,
    required bool searchHasCompleted,
  }) {
    if (score == null) return null;
    final color = isBestMove ? Colors.lightBlue[200] : Colors.lime;
    if (!searchHasCompleted && !isBookMove) return color?.withOpacity(0.3);
    return color;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoardNotifier>('boardNotifier', _boardNotifier));
  }
}
