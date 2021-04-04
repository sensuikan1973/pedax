import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class ShutdownRequest extends RequestSchema {
  const ShutdownRequest();
}

@immutable
class ShutdownResponse extends ResponseSchema<ShutdownRequest> {
  const ShutdownResponse({
    required ShutdownRequest request,
  }) : super(request);
}

ShutdownResponse executeShutdown(LibEdax edax, ShutdownRequest request) {
  edax
    ..edaxStop()
    ..libedaxTerminate()
    ..closeDll();
  return ShutdownResponse(request: request);
}
