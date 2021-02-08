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

  @override
  void initState() {
    super.initState();
    _board = widget.engine.edaxGetBoard();
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
    final turn = widget.engine.edaxGetCurrentPlayer();
    final move = y * 8 + x;
    var type = SquareType.empty;
    if (_board.squaresOfPlayer.contains(move)) {
      type = turn == TurnColor.black ? SquareType.black : SquareType.white;
    } else if (_board.squaresOfOpponent.contains(move)) {
      type = turn == TurnColor.black ? SquareType.white : SquareType.black;
    }

    return Square(
      type: type,
      length: _stoneSize,
      margin: _stoneMargin,
      coordinate: move2String(move),
    );
  }
}
