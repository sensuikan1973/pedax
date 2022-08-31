import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class InitRequest implements RequestSchema {
  const InitRequest();
}

@immutable
class InitResponse implements ResponseSchema<InitRequest> {
  const InitResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required this.request,
  });

  @override
  final InitRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

InitResponse executeInit(final LibEdax edax, final InitRequest request) {
  edax
    ..edaxStop()
    ..edaxInit();
  final moves = edax.edaxGetMoves();
  return InitResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
