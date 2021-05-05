import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class MoveRequest implements RequestSchema {
  const MoveRequest(this.move);

  final String move;
}

@immutable
class MoveResponse extends ResponseSchema<MoveRequest> {
  const MoveResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required MoveRequest request,
  }) : super(request);

  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

MoveResponse executeMove(LibEdax edax, MoveRequest request) {
  edax
    ..edaxStop()
    ..edaxMove(request.move);

  final lastMoveExcludingPass = edax.edaxGetLastMove();

  final currentColor = edax.edaxGetCurrentPlayer();
  if (edax.edaxGetMobilityCount(currentColor) == 0 && !edax.edaxIsGameOver()) {
    edax.edaxMove(currentColor == TurnColor.black ? MoveMark.passStringOfBlack : MoveMark.passStringOfWhite);
  }

  return MoveResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: edax.edaxGetMoves(),
    lastMove: lastMoveExcludingPass,
    request: request,
  );
}
