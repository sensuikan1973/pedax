import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class GetBookMoveWithPositionRequest extends RequestSchema {
  const GetBookMoveWithPositionRequest();
}

@immutable
class GetBookMoveWithPositionResponse extends ResponseSchema<GetBookMoveWithPositionRequest> {
  const GetBookMoveWithPositionResponse({
    required this.position,
    required this.moveList,
    required GetBookMoveWithPositionRequest request,
  }) : super(request);

  final Position position;
  final List<Move> moveList;
}

GetBookMoveWithPositionResponse executeGetBookMoveWithPosition(LibEdax edax, GetBookMoveWithPositionRequest request) {
  final result = edax.edaxGetBookMoveWithPosition();
  return GetBookMoveWithPositionResponse(
    position: result.position,
    moveList: result.moveList,
    request: request,
  );
}
