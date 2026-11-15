import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class RotateRequest implements RequestSchema {
  const RotateRequest({required this.angle});

  final int angle;
}

@immutable
class RotateResponse implements ResponseSchema<RotateRequest> {
  const RotateResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required this.request,
  });

  @override
  final RotateRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

RotateResponse executeRotate(LibEdax edax, RotateRequest request) {
  edax.edaxRotate(request.angle);
  final moves = edax.edaxGetMoves();
  return RotateResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
