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
    required this.logLevel,
  });

  final String movesAtRequest;
  final int playerLowerLimit;
  final int opponentLowerLimit;
  final Level logLevel;
}

@immutable
class CountBestpathResponse implements ResponseSchema<CountBestpathRequest> {
  const CountBestpathResponse({required this.rootMove, required this.countBestpathResult, required this.request});

  @override
  final CountBestpathRequest request;
  final String rootMove;

  /// NOTE:
  /// The color of the position in this result is the opposite of that in the request.
  /// It's due to executeCountBestpath algorithm and book/position structure.
  final CountBestpathResult countBestpathResult;
}

Stream<CountBestpathResponse> executeCountBestpath(final LibEdax edax, final CountBestpathRequest request) async* {
  final rootBookMoveListWithPosition = edax.edaxGetBookMoveWithPositionByMoves(request.movesAtRequest);
  final logger = Logger(level: request.logLevel);
  for (final move in rootBookMoveListWithPosition.moveList) {
    final currentMoves = edax.edaxGetMoves();
    if (currentMoves != request.movesAtRequest) {
      logger.d(
        'count bestpath process is aborted.\ncurrentMoves "$currentMoves" is not equal to movesAtRequest "${request.movesAtRequest}"',
      );
      edax.edaxBookStopCountBestpath();
      return;
    }

    edax.edaxBookStopCountBestpath();
    final moves = request.movesAtRequest + move.moveString;
    final bookMoveListWithPosition = edax.edaxGetBookMoveWithPositionByMoves(moves);

    final result = edax.edaxBookCountBoardBestpath(
      bookMoveListWithPosition.position.board,
      playerColor: edax.edaxGetCurrentPlayer(),
      playerLowerLimit: request.playerLowerLimit,
      opponentLowerLimit: request.opponentLowerLimit,
    );
    yield CountBestpathResponse(rootMove: move.moveString, countBestpathResult: result, request: request);
  }
}
