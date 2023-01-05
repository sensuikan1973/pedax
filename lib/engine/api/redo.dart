import 'package:libedax4dart/libedax4dart.dart';
import 'package:meta/meta.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class RedoRequest implements RequestSchema {
  const RedoRequest({required this.times});

  final int times;
}

@immutable
class RedoResponse implements ResponseSchema<RedoRequest> {
  const RedoResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required this.request,
  });

  @override
  final RedoRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

@doNotStore
RedoResponse executeRedo(final LibEdax edax, final RedoRequest request) {
  edax.edaxStop();
  for (var i = 0; i < request.times; i++) {
    edax.edaxRedo();
  }

  final lastMoveExcludingPass = edax.edaxGetLastMove();

  final currentColor = edax.edaxGetCurrentPlayer();
  if (edax.edaxGetMobilityCount(currentColor) == 0 && !edax.edaxIsGameOver()) {
    edax.edaxRedo();
  }

  return RedoResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: edax.edaxGetMoves(),
    lastMove: lastMoveExcludingPass,
    request: request,
  );
}
