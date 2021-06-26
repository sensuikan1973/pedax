import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class StopRequest implements RequestSchema {
  const StopRequest();
}

@immutable
class StopResponse implements ResponseSchema<StopRequest> {
  const StopResponse({required final this.request});

  @override
  final StopRequest request;
}

StopResponse executeStop(final LibEdax edax, final StopRequest request) {
  edax.edaxStop();
  return StopResponse(request: request);
}
