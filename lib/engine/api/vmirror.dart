import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class VmirrorRequest extends RequestSchema {
  const VmirrorRequest();

  @override
  String get name => 'vmirror';
}

@immutable
class VmirrorResponse extends ResponseSchema<VmirrorRequest> {
  const VmirrorResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required VmirrorRequest request,
  }) : super(request);

  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

VmirrorResponse executeVmirror(LibEdax edax, VmirrorRequest request) {
  edax.edaxVmirror();
  final moves = edax.edaxGetMoves();
  return VmirrorResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: moves,
    lastMove: moves.isEmpty ? null : edax.edaxGetLastMove(),
    request: request,
  );
}
