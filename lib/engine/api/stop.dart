import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class StopRequest extends RequestSchema {
  const StopRequest();

  @override
  String get name => 'stop';
}

@immutable
class StopResponse extends ResponseSchema<StopRequest> {
  const StopResponse({
    required StopRequest request,
  }) : super(request);
}

StopResponse executeStop(LibEdax edax, StopRequest request) {
  edax.edaxStop();
  return StopResponse(request: request);
}
