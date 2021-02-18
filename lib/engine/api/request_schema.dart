import 'package:flutter/foundation.dart';

@immutable
abstract class RequestSchema {
  const RequestSchema();

  String get name;
}
