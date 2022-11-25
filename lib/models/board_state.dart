import 'dart:collection';

import 'package:libedax4dart/libedax4dart.dart';
import 'package:meta/meta.dart';

class BoardState {
  BoardState();

  late Board board;
  late UnmodifiableListView<int> squaresOfPlayer;
  late UnmodifiableListView<int> squaresOfOpponent;
  late int currentColor;
  late Move? lastMove;

  late int level;
  late bool hintStepByStep;
  late bool countBestpathAvailability;
  UnmodifiableListView<HintWithStepByStep> hintsWithStepByStep = UnmodifiableListView([]);
  UnmodifiableListView<CountBestpathResultWithMove> countBestpathList = UnmodifiableListView([]);
  bool edaxInitOnce = false;
  String currentMoves = '';
  BookLoadStatus? bookLoadStatus;
  bool hintIsVisible = true;
  bool edaxServerSpawned = false;
  int bestScore = 0;
  int positionWinsNum = 0;
  int positionLossesNum = 0;
  int positionDrawsNum = 0;
  BoardMode mode = BoardMode.freePlay;
  ArrangeTargetType arrangeTargetSquareType = ArrangeTargetType.black;

  bool get bookHasBeenLoaded =>
      bookLoadStatus == BookLoadStatus.loaded || bookLoadStatus == BookLoadStatus.notifiedToUser;

  int get positionFullNum => positionWinsNum + positionLossesNum + positionDrawsNum;

  int get blackDiscCount => currentColor == TurnColor.black ? squaresOfPlayer.length : squaresOfOpponent.length;
  int get whiteDiscCount => currentColor == TurnColor.white ? squaresOfPlayer.length : squaresOfOpponent.length;
  int get emptyNum => 64 - blackDiscCount - whiteDiscCount;

  String get currentMovesWithoutPassString => currentMoves.replaceAll(
        RegExp('(${MoveMark.passStringOfBlack})|(${MoveMark.passStringOfWhite})'),
        '',
      );
  int get currentMovesCountWithoutPass => currentMovesWithoutPassString.length ~/ 2;
  String get arrangeTargetChar {
    if (arrangeTargetSquareType == ArrangeTargetType.black) return ColorChar.black;
    if (arrangeTargetSquareType == ArrangeTargetType.white) return ColorChar.white;
    return ColorChar.empty;
  }
}

enum BoardMode { freePlay, arrangeDiscs }

enum BookLoadStatus { loading, loaded, notifiedToUser }

enum ArrangeTargetType { black, white, empty }

@immutable
class CountBestpathResultWithMove {
  const CountBestpathResultWithMove({
    required this.countBestpathList,
    required this.rootMove,
  });
  final CountBestpathResult countBestpathList;
  final String rootMove;
}

@immutable
class HintWithStepByStep {
  const HintWithStepByStep({
    required this.hint,
    required this.isLastStep,
  });
  final Hint hint;
  final bool isLastStep;
}
