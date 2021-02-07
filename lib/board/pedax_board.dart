import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:libedax4dart/libedax4dart.dart';

class PedaxBoard extends StatelessWidget {
  const PedaxBoard(this.libEdax, this.length, {Key? key}) : super(key: key);

  final LibEdax libEdax;
  final double length;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _blackStoneImage,
            _whiteStoneImage,
            Text(libEdax.edaxGetBoard().prettyString(TurnColor.black)),
          ],
        ),
      );

  int get _boardSize => 8;
  double get _marginForStones => (length / _boardSize) * 0.1;
  double get _stoneSize => (length / _boardSize) - (_marginForStones * 2);
  Image get _blackStoneImage => Image.asset('assets/images/black_stone.png', fit: BoxFit.contain, height: _stoneSize);
  Image get _whiteStoneImage => Image.asset('assets/images/white_stone.png', fit: BoxFit.contain, height: _stoneSize);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DoubleProperty('length', length))..add(DiagnosticsProperty<LibEdax>('libEdax', libEdax));
  }
}
