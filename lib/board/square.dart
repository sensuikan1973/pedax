import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Square extends StatelessWidget {
  const Square({
    required final this.type,
    required final this.length,
    required final this.margin,
    required final this.coordinate,
    final this.onTap,
    final this.score,
    final this.bestPathNumOfBlack,
    final this.bestPathNumOfWhite,
    final this.scoreColor,
    final this.isLastMove = false,
    final this.isBookMove = false,
    final Key? key,
  }) : super(key: key);

  final SquareType type;
  final double length;
  final double margin; // margin to image
  final String coordinate;
  final Function()? onTap;
  final int? score;
  final int? bestPathNumOfBlack;
  final int? bestPathNumOfWhite;
  final Color? scoreColor;
  final bool isLastMove;
  final bool isBookMove;
  double get _scoreFontSize => length * 0.45;
  double get _bestPathNumFontSize => length * 0.25;
  double get _notebookEmojiFontSize => length * 0.25;

  @override
  Widget build(final BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(margin),
          child: isLastMove ? Stack(children: [_stone, _lastMoveMark()]) : _stone,
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('margin', margin))
      ..add(DoubleProperty('length', length))
      ..add(EnumProperty<SquareType>('type', type))
      ..add(StringProperty('coordinate', coordinate))
      ..add(DiagnosticsProperty<Function()>('onTap', onTap))
      ..add(IntProperty('score', score))
      ..add(IntProperty('bestPathNumOfBlack', bestPathNumOfBlack))
      ..add(IntProperty('bestPathNumOfWhite', bestPathNumOfWhite))
      ..add(DiagnosticsProperty<bool>('isLastMove', isLastMove))
      ..add(DiagnosticsProperty<bool>('isBookMove', isBookMove))
      ..add(ColorProperty('scoreColor', scoreColor));
  }

  Widget get _stone {
    switch (type) {
      case SquareType.black:
        return Container(
          width: length,
          height: length,
          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        );
      case SquareType.white:
        return Container(
          width: length,
          height: length,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all()),
        );
      case SquareType.empty:
        return score != null ? _evaluationText() : SizedBox(height: length, width: length);
    }
  }

  SizedBox _evaluationText() {
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
                if (bestPathNumOfBlack != null) Positioned(bottom: 0, left: 0, child: _bestPathNumOfBlackText),
                if (bestPathNumOfWhite != null) Positioned(bottom: 0, right: 0, child: _bestPathNumOfWhiteText)
              ],
            )
          : Center(child: scoreText),
    );
  }

  Text get _bestPathNumOfBlackText => Text(
        bestPathNumOfBlack.toString(),
        style: TextStyle(
          fontSize: _bestPathNumFontSize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );

  Text get _bestPathNumOfWhiteText => Text(
        bestPathNumOfWhite.toString(),
        style: TextStyle(
          fontSize: _bestPathNumFontSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

  Container _lastMoveMark() => Container(
        height: length / 3,
        width: length / 3,
        margin: EdgeInsets.all(length / 3),
        color: Colors.red,
      );

  String _scoreString(final int score) => score >= 0 ? '+$score' : score.toString();
}

enum SquareType { black, white, empty }
