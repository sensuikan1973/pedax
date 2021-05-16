import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class StreamOfBestPathNumWithLinkRequest implements RequestSchema {
  const StreamOfBestPathNumWithLinkRequest({
    required this.movesAtRequest,
    this.level = 10, // TODO: consider default value
  });

  final String movesAtRequest;
  final int level;
}

@immutable
class StreamOfBestPathNumWithLinkResponse implements ResponseSchema<StreamOfBestPathNumWithLinkRequest> {
  const StreamOfBestPathNumWithLinkResponse({
    required this.bestPathNumWithLink,
    required this.request,
  });

  @override
  final StreamOfBestPathNumWithLinkRequest request;
  final BestPathNumWithLink bestPathNumWithLink;
}

Stream<StreamOfBestPathNumWithLinkResponse> executeStreamOfBestPathNumWithLink(
  LibEdax edax,
  StreamOfBestPathNumWithLinkRequest request,
) {
  final stream = edax.streamOfBestPathNumWithLink(level: request.level);
  return stream.asyncMap((event) => StreamOfBestPathNumWithLinkResponse(bestPathNumWithLink: event, request: request));
}
