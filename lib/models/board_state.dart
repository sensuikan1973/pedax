import 'dart:async';

import 'package:meta/meta.dart';
import 'package:libedax4dart/libedax4dart.dart';

// @immutable
@doNotStore
class BoardState {
  BoardState();

  late Board board;
  late List<int> squaresOfPlayer;
  late List<int> squaresOfOpponent;
  late int currentColor;
  late Move? lastMove;
  late String currentMoves;
  final List<Hint> hints = [];
  final Completer<bool> edaxInit = Completer<bool>();

  late int level;
  late bool hintStepByStep;
  bool bookLoading = false;
  bool hintIsVisible = true;
  int bestScore = 0;
  int positionWinsNum = 0;
  int positionLossesNum = 0;
  int positionDrawsNum = 0;

  int get positionFullNum => positionWinsNum + positionLossesNum + positionDrawsNum;
  int get positionWinsRate => (positionWinsNum / positionFullNum * 100).floor();
  int get positionDrawsRate => (positionDrawsNum / positionFullNum * 100).floor();
}
