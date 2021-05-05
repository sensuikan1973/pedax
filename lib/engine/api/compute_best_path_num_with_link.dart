import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class ComputeBestPathNumWithLinkRequest implements RequestSchema {
  const ComputeBestPathNumWithLinkRequest({
    required this.movesAtRequest,
    this.level = 10, // TODO: consider default value
  });

  final String movesAtRequest;
  final int level;
}

@immutable
class ComputeBestPathNumWithLinkResponse implements ResponseSchema<ComputeBestPathNumWithLinkRequest> {
  const ComputeBestPathNumWithLinkResponse({
    required this.bestPathNumWithLinkList,
    required this.request,
  });

  @override
  final ComputeBestPathNumWithLinkRequest request;
  final List<BestPathNumWithLink> bestPathNumWithLinkList;
}

ComputeBestPathNumWithLinkResponse executeComputeBestPathNumWithLink(
  LibEdax edax,
  ComputeBestPathNumWithLinkRequest request,
) {
  final result = edax.computeBestPathNumWithLink(level: request.level);
  return ComputeBestPathNumWithLinkResponse(bestPathNumWithLinkList: result, request: request);
}
