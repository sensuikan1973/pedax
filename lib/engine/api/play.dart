import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class PlayRequest implements RequestSchema {
  const PlayRequest(this.moves);

  final String moves;
}

@immutable
class PlayResponse implements ResponseSchema<PlayRequest> {
  const PlayResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required this.request,
  });

  @override
  final PlayRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

PlayResponse executePlay(final LibEdax edax, final PlayRequest request) {
  edax
    ..edaxStop()
    ..edaxPlay(request.moves);
  final moves = edax.edaxGetMoves();
  return PlayResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
