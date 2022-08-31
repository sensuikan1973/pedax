import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class NewRequest implements RequestSchema {
  const NewRequest();
}

@immutable
class NewResponse implements ResponseSchema<NewRequest> {
  const NewResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required this.request,
  });

  @override
  final NewRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

NewResponse executeNew(final LibEdax edax, final NewRequest request) {
  edax
    ..edaxStop()
    ..edaxNew();
  final moves = edax.edaxGetMoves();
  return NewResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
