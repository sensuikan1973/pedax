import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class MoveRequest extends RequestSchema {
  const MoveRequest(this.move, {required Logger logger}) : super(logger: logger);

  final String move;

  @override
  String get name => 'move';
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
  edax.edaxStop();
  request.logger!.d('stopped edax serach');
  edax.edaxMove(request.move);
  request.logger!.d('moved "${request.move}"');
  final moves = edax.edaxGetMoves();
  request.logger!.d('current moves: $moves');
  return MoveResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
