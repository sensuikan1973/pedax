import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class ComputeBestPathNumWithLinkRequest extends RequestSchema {
  const ComputeBestPathNumWithLinkRequest({
    required this.movesAtRequest,
  });

  final String movesAtRequest;
}

@immutable
class ComputeBestPathNumWithLinkResponse extends ResponseSchema<ComputeBestPathNumWithLinkRequest> {
  const ComputeBestPathNumWithLinkResponse({
    required this.bestPathNumWithLinkList,
    required ComputeBestPathNumWithLinkRequest request,
  }) : super(request);

  final List<BestPathNumWithLink> bestPathNumWithLinkList;
}

ComputeBestPathNumWithLinkResponse executeComputeBestPathNumWithLink(
  LibEdax edax,
  ComputeBestPathNumWithLinkRequest request,
) {
  final result = edax.computeBestPathNumWithLink();
  return ComputeBestPathNumWithLinkResponse(bestPathNumWithLinkList: result, request: request);
}
