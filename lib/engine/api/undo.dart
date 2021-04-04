import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class UndoRequest extends RequestSchema {
  const UndoRequest({required this.times});

  final int times;
}

@immutable
class UndoResponse extends ResponseSchema<UndoRequest> {
  const UndoResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required UndoRequest request,
  }) : super(request);

  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

UndoResponse executeUndo(LibEdax edax, UndoRequest request) {
  edax.edaxStop();
  if (edax.edaxGetLastMove().isPass) edax.edaxUndo();
  for (var i = 0; i < request.times; i++) {
    edax.edaxUndo();
  }

  if (edax.edaxGetLastMove().isPass) edax.edaxUndo();
  final lastMoveExcludingPass = edax.edaxGetLastMove();
  final currentColor = edax.edaxGetCurrentPlayer();
  if (edax.edaxGetMobilityCount(currentColor) == 0 && !edax.edaxIsGameOver()) {
    edax.edaxRedo();
  }

  return UndoResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: edax.edaxGetMoves(),
    lastMove: lastMoveExcludingPass,
    request: request,
  );
}
