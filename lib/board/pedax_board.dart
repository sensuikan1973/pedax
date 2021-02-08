import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'square.dart';

class PedaxBoard extends StatelessWidget {
  const PedaxBoard(this.engine, this.length, {Key? key}) : super(key: key);

  final LibEdax engine;
  final double length;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: length,
        width: length,
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
  double get _stoneMargin => (length / _boardSize) * 0.1;
  double get _stoneSize => (length / _boardSize) - (_stoneMargin * 2);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DoubleProperty('length', length))..add(DiagnosticsProperty<LibEdax>('libEdax', engine));
  }

  Square _square(int y, int x) => Square(
        type: SquareType.black,
        length: _stoneSize,
        margin: _stoneMargin,
        coordinate: move2String(y * 8 + x),
      );
}
