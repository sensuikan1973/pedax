import 'package:flutter/foundation.dart';

// We can pass `Object` instance to `EdaxServer port`.
// It's because `EdaxServer` isolate and Flutter root isolate share the same code.
// See: https://api.dart.dev/dev/2.13.0-38.0.dev/dart-isolate/Isolate/spawn.html
// See: https://api.dart.dev/dev/dart-isolate/SendPort/send.html

@immutable
abstract class RequestSchema {
  const RequestSchema();

  String get name;
}
