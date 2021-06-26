import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class ComputeBestPathNumWithLinkRequest implements RequestSchema {
  const ComputeBestPathNumWithLinkRequest({
    required final this.movesAtRequest,
    final this.level = 10, // TODO: consider default value
  });

  final String movesAtRequest;
  final int level;
}

@immutable
class ComputeBestPathNumWithLinkResponse implements ResponseSchema<ComputeBestPathNumWithLinkRequest> {
  const ComputeBestPathNumWithLinkResponse({
    required final this.bestPathNumWithLinkList,
    required final this.request,
  });

  @override
  final ComputeBestPathNumWithLinkRequest request;
  final List<BestPathNumWithLink> bestPathNumWithLinkList;
}

ComputeBestPathNumWithLinkResponse executeComputeBestPathNumWithLink(
  final LibEdax edax,
  final ComputeBestPathNumWithLinkRequest request,
) {
  final result = edax.computeBestPathNumWithLink(level: request.level);
  return ComputeBestPathNumWithLinkResponse(bestPathNumWithLinkList: result, request: request);
}
