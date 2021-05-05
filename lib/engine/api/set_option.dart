import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class SetOptionRequest<T extends Object> implements RequestSchema {
  const SetOptionRequest(this.optionName, this.val);

  final String optionName;
  final T val;
}

@immutable
class SetOptionResponse extends ResponseSchema<SetOptionRequest> {
  const SetOptionResponse({
    required SetOptionRequest request,
  }) : super(request);
}

SetOptionResponse executeSetOption<T extends Object>(LibEdax edax, SetOptionRequest<T> request) {
  edax
    ..edaxStop()
    ..edaxSetOption(request.optionName, request.val.toString());
  return SetOptionResponse(request: request);
}
