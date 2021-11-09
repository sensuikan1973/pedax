import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class SetboardRequest implements RequestSchema {
  const SetboardRequest(this.board);

  final String board;
}

@immutable
class SetboardResponse implements ResponseSchema<SetboardRequest> {
  const SetboardResponse({
    required final this.board,
    required final this.currentColor,
    required final this.moves,
    required final this.lastMove,
    required final this.request,
  });

  @override
  final SetboardRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

SetboardResponse executeSetboard(final LibEdax edax, final SetboardRequest request) {
  edax
    ..edaxStop()
    ..edaxSetboard(request.board);

  return SetboardResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: edax.edaxGetMoves(),
    lastMove: edax.edaxGetLastMove(),
    request: request,
  );
}
