import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class CountBestpathRequest implements RequestSchema {
  const CountBestpathRequest({
    required final this.movesAtRequest,
    required final this.logger,
  });

  final String movesAtRequest;
  final Logger logger;
}

@immutable
class CountBestpathResponse implements ResponseSchema<CountBestpathRequest> {
  const CountBestpathResponse({
    required final this.rootMove,
    required final this.countBestpathResult,
    required final this.request,
  });

  @override
  final CountBestpathRequest request;
  final String rootMove;

  /// NOTE:
  /// The color of the position in this result is the opposite of that in the request.
  /// It's due to executeCountBestpath algorism and book/position structure.
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
    // TODO: replace
    // ignore: deprecated_member_use
    final result = edax.edaxBookCountBestpath(bookMoveListWithPosition.position.board);
    yield CountBestpathResponse(
      rootMove: move.moveString,
      countBestpathResult: result,
      request: request,
    );
  }
}
