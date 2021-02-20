import 'package:flutter/foundation.dart';
import 'request_schema.dart';

@immutable
abstract class ResponseSchema<T extends RequestSchema> {
  const ResponseSchema(this.request);

  final T request;
}
