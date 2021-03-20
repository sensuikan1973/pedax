import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Square extends StatelessWidget {
  const Square({
    required this.type,
    required this.length,
    required this.margin,
    required this.coordinate,
    this.onTap,
    this.score,
    this.scoreColor,
    this.isLastMove = false,
    this.isBookMove = false,
    Key? key,
  }) : super(key: key);

  final SquareType type;
  final double length;
  final double margin; // margin to image
  final String coordinate;
  final Function()? onTap;
  final int? score;
  final Color? scoreColor;
  final bool isLastMove;
  final bool isBookMove;
  double get _scoreFontSize => length * 0.45;
  double get _notebookEmojiFontSize => length * 0.25;

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
      ..add(DiagnosticsProperty<bool>('isBookMove', isBookMove))
      ..add(ColorProperty('scoreColor', scoreColor));
  }

  Widget get _stone {
    switch (type) {
      case SquareType.black:
        return const Text('●');
      // return Container(
      //   width: length,
      //   height: length,
      //   decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      // );
      case SquareType.white:
        return const Text('◯');
      // return Container(
      //   width: length,
      //   height: length,
      //   decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all()),
      // );
      case SquareType.empty:
        return score != null ? _scoreText() : SizedBox(height: length, width: length);
    }
  }

  SizedBox _scoreText() {
    final scoreText = Text(
      _scoreString(score!),
      style: TextStyle(color: scoreColor, fontSize: _scoreFontSize),
    );
    return SizedBox(
      height: length,
      width: length,
      child: isBookMove
          ? Stack(
              children: [
                Center(child: scoreText),
                Positioned(
                  top: 0,
                  right: 0,
                  // REF: https://emojipedia.org/notebook/
                  child: Text('📓', style: TextStyle(fontSize: _notebookEmojiFontSize)),
                ),
              ],
            )
          : Center(child: scoreText),
    );
  }

  Container _lastMoveMark() => Container(
        height: length / 3,
        width: length / 3,
        margin: EdgeInsets.all(length / 3),
        color: Colors.red,
      );

  String _scoreString(int score) => score >= 0 ? '+$score' : score.toString();
}

enum SquareType { black, white, empty }
