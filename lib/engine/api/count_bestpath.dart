import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class CountBestpathRequest implements RequestSchema {
  const CountBestpathRequest({
    required this.movesAtRequest,
    required this.playerLowerLimit,
    required this.opponentLowerLimit,
    required this.logger,
  });

  final String movesAtRequest;
  final int playerLowerLimit;
  final int opponentLowerLimit;
  final Logger logger;
}

@immutable
class CountBestpathResponse implements ResponseSchema<CountBestpathRequest> {
  const CountBestpathResponse({
    required this.rootMove,
    required this.countBestpathResult,
    required this.request,
  });

  @override
  final CountBestpathRequest request;
  final String rootMove;

  final CountBestpathResult countBestpathResult;
}

Stream<CountBestpathResponse> executeCountBestpath(
  final LibEdax edax,
  final CountBestpathRequest request,
) async* {
  final rootBookMoveListWithPosition = edax.edaxGetBookMoveWithPositionByMoves(request.movesAtRequest);
  for (final move in rootBookMoveListWithPosition.moveList) {
    final currentMoves = edax.edaxGetMoves();
    if (currentMoves != request.movesAtRequest) {
      request.logger.d(
        'count bestpath process is aborted.\ncurrentMoves "$currentMoves" is not equal to movesAtRequest "${request.movesAtRequest}"',
      );
      edax.edaxBookStopCountBestpath();
      return;
    }

    edax.edaxBookStopCountBestpath();
    final moves = request.movesAtRequest + move.moveString;
    final bookMoveListWithPosition = edax.edaxGetBookMoveWithPositionByMoves(moves);
    final board = bookMoveListWithPosition.position.board;

    final symetryMoveX = symetryMove(move.x, bookMoveListWithPosition.symetry);
    final lastMoveSquarePlayer = edax.edaxBoardGetSquareColor(board, symetryMoveX);
    int positionPlayerColor = -1; // empty.
    if (lastMoveSquarePlayer == 0) {
      positionPlayerColor = edax.edaxGetCurrentPlayer();
    } else if (lastMoveSquarePlayer == 1) {
      positionPlayerColor = edax.edaxGetOpponentPlayer();
    }

    final result = edax.edaxBookCountBoardBestpath(
      board,
      playerColor: positionPlayerColor,
      playerLowerLimit: request.playerLowerLimit,
      opponentLowerLimit: request.opponentLowerLimit,
    );
    yield CountBestpathResponse(
      rootMove: move.moveString,
      countBestpathResult: result,
      request: request,
    );
  }
}
