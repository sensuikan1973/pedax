import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  const Square({
    required this.type,
    required this.length,
    required this.margin,
    required this.coordinate,
    this.onTap,
    this.score,
    this.scoreColor = Colors.black,
    this.isLastMove = false,
    Key? key,
  }) : super(key: key);

  final SquareType type;
  final double length;
  final double margin; // margin to image
  final String coordinate;
  final Function()? onTap;
  final int? score;
  final Color scoreColor;
  final bool isLastMove;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(margin),
          child: isLastMove ? Stack(children: [_stone, _lastMoveMark()]) : _stone,
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('margin', margin))
      ..add(DoubleProperty('length', length))
      ..add(EnumProperty<SquareType>('type', type))
      ..add(StringProperty('coordinate', coordinate))
      ..add(DiagnosticsProperty<Function()>('onTap', onTap))
      ..add(IntProperty('score', score))
      ..add(DiagnosticsProperty<bool>('isLastMove', isLastMove))
      ..add(ColorProperty('scoreColor', scoreColor));
  }

  Widget get _stone {
    switch (type) {
      case SquareType.black:
        return Image.asset('assets/images/black_stone.png', fit: BoxFit.contain, height: length, width: length);
      case SquareType.white:
        return Image.asset('assets/images/white_stone.png', fit: BoxFit.contain, height: length, width: length);
      case SquareType.empty:
        return score != null ? _scoreText() : SizedBox(height: length, width: length);
    }
  }

  SizedBox _scoreText() => SizedBox(
        height: length,
        width: length,
        child: Center(
          child: Text(
            score! > 0 ? '+$score' : score.toString(),
            style: TextStyle(color: scoreColor),
          ),
        ),
      );

  Container _lastMoveMark() => Container(
        height: length / 3,
        width: length / 3,
        margin: EdgeInsets.all(length / 3),
        color: Colors.red,
      );
}

enum SquareType { black, white, empty }
