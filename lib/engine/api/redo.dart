import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class RedoRequest extends RequestSchema {
  const RedoRequest({required this.times});
  final int times;

  @override
  String get name => 'redo';
}

@immutable
class RedoResponse extends ResponseSchema<RedoRequest> {
  const RedoResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required RedoRequest request,
  }) : super(request);

  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

RedoResponse executeRedo(LibEdax edax, RedoRequest request) {
  edax.edaxStop();
  for (var i = 0; i < request.times; i++) {
    edax.edaxRedo();
  }
  final moves = edax.edaxGetMoves();
  return RedoResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
