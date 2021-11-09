import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class SquareReplacement {
  const SquareReplacement(this.offset, this.color);

  final int offset; // a.k.a move(int)
  final int color;
}

@immutable
class SetboardRequest implements RequestSchema {
  const SetboardRequest({
    required this.currentColor,
    required this.replacementTargets,
    required final this.logger,
  });

  final int currentColor;
  final List<SquareReplacement> replacementTargets;
  final Logger logger;
}

@immutable
class SetboardResponse implements ResponseSchema<SetboardRequest> {
  const SetboardResponse({
    required final this.board,
    required final this.currentColor,
    required final this.moves,
    required final this.lastMove,
    required final this.request,
  });

  @override
  final SetboardRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

SetboardResponse executeSetboard(final LibEdax edax, final SetboardRequest request) {
  edax.edaxStop();

  final board = edax.edaxGetBoard();
  var boardStr = board.stringApplicableToSetboard(edax.edaxGetCurrentPlayer());
  for (final replacementTarget in request.replacementTargets) {
    final colorChar = replacementTarget.color == TurnColor.black ? '*' : 'O';
    boardStr = boardStr.replaceFirst(RegExp('.'), colorChar, replacementTarget.offset);
  }
  final currentColorChar = request.currentColor == TurnColor.black ? '*' : 'O';
  boardStr = boardStr.replaceFirst(RegExp('.'), currentColorChar, 64);

  request.logger.d('setboard $boardStr');
  edax.edaxSetboard(boardStr);

  return SetboardResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: edax.edaxGetMoves(),
    lastMove: edax.edaxGetLastMove(),
    request: request,
  );
}
