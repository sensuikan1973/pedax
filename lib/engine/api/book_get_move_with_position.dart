import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class GetBookMoveWithPositionRequest implements RequestSchema {
  const GetBookMoveWithPositionRequest();
}

@immutable
class GetBookMoveWithPositionResponse implements ResponseSchema<GetBookMoveWithPositionRequest> {
  const GetBookMoveWithPositionResponse({
    required this.position,
    required this.moveList,
    required this.request,
  });

  @override
  final GetBookMoveWithPositionRequest request;
  final Position position;
  final List<Move> moveList;
}

GetBookMoveWithPositionResponse executeGetBookMoveWithPosition(
  final LibEdax edax,
  final GetBookMoveWithPositionRequest request,
) {
  final result = edax.edaxGetBookMoveWithPosition();
  return GetBookMoveWithPositionResponse(
    position: result.position,
    moveList: result.moveList,
    request: request,
  );
}
