import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'square.dart';

class PedaxBoard extends StatefulWidget {
  const PedaxBoard(this.engine, this.length, {Key? key}) : super(key: key);

  final LibEdax engine;
  final double length;

  @override
  _PedaxBoardState createState() => _PedaxBoardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DoubleProperty('length', length))..add(DiagnosticsProperty<LibEdax>('libEdax', engine));
  }
}

class _PedaxBoardState extends State<PedaxBoard> {
  late Board _board;
  late List<int> _squaresOfPlayer;
  late List<int> _squaresOfOpponent;
  late int _currentColor;
  late String _moves;
  late List<Hint> _hints;
  late Move? _lastMove;
  late int? _bestScore;

  @override
  void initState() {
    super.initState();
    updateState();
  }

  void updateState() {
    _board = widget.engine.edaxGetBoard();
    _squaresOfPlayer = _board.squaresOfPlayer;
    _squaresOfOpponent = _board.squaresOfOpponent;
    _currentColor = widget.engine.edaxGetCurrentPlayer();
    _moves = widget.engine.edaxGetMoves();
    _lastMove = _moves.isEmpty ? null : widget.engine.edaxGetLastMove();
    _hints = widget.engine.edaxHint(2); // for now, n is 2 and synchronous.
    _bestScore = _hints.isEmpty ? null : _hints.map<int>((h) => h.score).reduce(max);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.length,
        width: widget.length,
        child: Table(
          children: List.generate(
            _boardSize,
            (yIndex) => TableRow(
              children: List.generate(
                _boardSize,
                (xIndex) => _square(yIndex, xIndex),
              ),
            ),
          ),
        ),
      );

  int get _boardSize => 8;
  double get _stoneMargin => (widget.length / _boardSize) * 0.1;
  double get _stoneSize => (widget.length / _boardSize) - (_stoneMargin * 2);

  Square _square(int y, int x) {
    final move = y * 8 + x;
    final type = _squareType(move);
    final moveString = move2String(move);
    final targetHints = _hints.where((h) => h.move == move).toList();
    final hint = targetHints.isEmpty ? null : targetHints.first;
    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: moveString,
      isLastMove: _lastMove?.x == move,
      score: hint?.score,
      scoreColor: _scoreColor(hint?.score, hint?.score == _bestScore),
      onTap: type != SquareType.empty
          ? null
          : () => setState(() {
                widget.engine.edaxMove(moveString);
                updateState();
              }),
    );
  }

  SquareType _squareType(int move) {
    final isBlackTurn = _currentColor == TurnColor.black;
    if (_squaresOfPlayer.contains(move)) {
      return isBlackTurn ? SquareType.black : SquareType.white;
    }
    if (_squaresOfOpponent.contains(move)) {
      return isBlackTurn ? SquareType.white : SquareType.black;
    }
    return SquareType.empty;
  }

  Color? _scoreColor(int? score, bool bestMove) {
    if (score == null) return null;
    if (score == 0) {
      if (bestMove) return Colors.cyan;
      return Colors.cyan[900];
    } else if (score > 0) {
      if (bestMove) return Colors.blue;
      return Colors.blue[900];
    } else /* score < 0*/ {
      if (bestMove) return Colors.lime;
      return Colors.lime[900];
    }
  }
}
