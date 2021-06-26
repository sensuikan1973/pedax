import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class UndoRequest implements RequestSchema {
  const UndoRequest({required final this.times});

  final int times;
}

@immutable
class UndoResponse implements ResponseSchema<UndoRequest> {
  const UndoResponse({
    required final this.board,
    required final this.currentColor,
    required final this.moves,
    required final this.lastMove,
    required final this.request,
  });

  @override
  final UndoRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

UndoResponse executeUndo(final LibEdax edax, final UndoRequest request) {
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
