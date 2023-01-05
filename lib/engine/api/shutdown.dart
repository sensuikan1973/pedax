import 'package:libedax4dart/libedax4dart.dart';
import 'package:meta/meta.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class ShutdownRequest implements RequestSchema {
  const ShutdownRequest();
}

@immutable
class ShutdownResponse implements ResponseSchema<ShutdownRequest> {
  const ShutdownResponse({required this.request});

  @override
  final ShutdownRequest request;
}

@doNotStore
ShutdownResponse executeShutdown(final LibEdax edax, final ShutdownRequest request) {
  edax
    ..edaxStop()
    ..libedaxTerminate()
    ..closeDll();
  return ShutdownResponse(request: request);
}
