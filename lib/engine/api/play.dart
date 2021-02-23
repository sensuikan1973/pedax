import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

final _logger = Logger();

@immutable
class PlayRequest extends RequestSchema {
  const PlayRequest(this.moves);

  final String moves;

  @override
  String get name => 'play';
}

@immutable
class PlayResponse extends ResponseSchema<PlayRequest> {
  const PlayResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required PlayRequest request,
  }) : super(request);

  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

PlayResponse executePlay(LibEdax edax, PlayRequest request) {
  edax.edaxStop();
  _logger.d('stopped edax serach');
  edax.edaxPlay(request.moves);
  _logger.d('played "${request.moves}"');
  final moves = edax.edaxGetMoves();
  _logger.d('current moves: $moves');
  return PlayResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
