import 'dart:collection';

import 'package:libedax4dart/libedax4dart.dart';

class BoardState {
  BoardState();

  late Board board;
  late UnmodifiableListView<int> squaresOfPlayer;
  late UnmodifiableListView<int> squaresOfOpponent;
  late int currentColor;
  late Move? lastMove;

  late int level;
  late bool hintStepByStep;
  UnmodifiableListView<Hint> hints = UnmodifiableListView([]);
  bool edaxInitOnce = false;
  String currentMoves = '';
  BookLoadStatus? bookLoadStatus;
  bool hintIsVisible = true;
  bool edaxServerSpawned = false;
  int bestScore = 0;
  int positionWinsNum = 0;
  int positionLossesNum = 0;
  int positionDrawsNum = 0;

  int get positionFullNum => positionWinsNum + positionLossesNum + positionDrawsNum;

  int get blackDiscCount => currentColor == TurnColor.black ? squaresOfPlayer.length : squaresOfOpponent.length;
  int get whiteDiscCount => currentColor == TurnColor.white ? squaresOfPlayer.length : squaresOfOpponent.length;

  String get currentMovesWithoutPassString => currentMoves.replaceAll(
        RegExp('(${MoveMark.passString})|(${MoveMark.passString.toUpperCase()})'),
        '',
      );
  int get currentMovesCountWithoutPass => currentMovesWithoutPassString.length ~/ 2;
}

enum BookLoadStatus { loading, loaded, notifiedToUser }
