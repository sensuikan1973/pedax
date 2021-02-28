import 'dart:collection';

import 'package:libedax4dart/libedax4dart.dart';

class BoardState {
  BoardState();

  late Board board;
  late List<int> squaresOfPlayer;
  late List<int> squaresOfOpponent;
  late int currentColor;
  late Move? lastMove;

  late int level;
  late bool hintStepByStep;
  UnmodifiableListView<Hint> hints = UnmodifiableListView([]);
  bool edaxInitOnce = false;
  String currentMoves = '';
  BookLoadStatus bookLoadStatus = BookLoadStatus.loading;
  bool hintIsVisible = true;
  bool edaxServerSpawned = false;
  int bestScore = 0;
  int positionWinsNum = 0;
  int positionLossesNum = 0;
  int positionDrawsNum = 0;

  int get positionFullNum => positionWinsNum + positionLossesNum + positionDrawsNum;
  int get positionWinsRate => (positionWinsNum / positionFullNum * 100).floor();
  int get positionDrawsRate => (positionDrawsNum / positionFullNum * 100).floor();
}

enum BookLoadStatus { loading, loaded, notifiedToUser }
