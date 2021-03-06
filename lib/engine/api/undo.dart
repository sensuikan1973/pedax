import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class UndoRequest extends RequestSchema {
  const UndoRequest({required this.times});

  final int times;

  @override
  String get name => 'undo';
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
  for (var i = 0; i < request.times; i++) {
    edax.edaxUndo();
  }
  final moves = edax.edaxGetMoves();
  return UndoResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
