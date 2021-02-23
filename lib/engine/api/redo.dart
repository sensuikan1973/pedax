import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

final _logger = Logger();

@immutable
class RedoRequest extends RequestSchema {
  const RedoRequest();

  @override
  String get name => 'undo';
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
  _logger.d('stopped edax serach');
  edax.edaxRedo();
  _logger.d('redo');
  final moves = edax.edaxGetMoves();
  _logger.d('current moves: $moves');
  return RedoResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
