import 'package:libedax4dart/libedax4dart.dart';
import 'package:meta/meta.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class SetOptionRequest<T extends Object> implements RequestSchema {
  const SetOptionRequest(this.optionName, this.val);

  final String optionName;
  final T val;
}

@immutable
class SetOptionResponse implements ResponseSchema<SetOptionRequest> {
  const SetOptionResponse({required this.request});

  @override
  final SetOptionRequest request;
}

@doNotStore
SetOptionResponse executeSetOption<T extends Object>(final LibEdax edax, final SetOptionRequest<T> request) {
  edax
    ..edaxStop()
    ..edaxSetOption(request.optionName, request.val.toString());
  return SetOptionResponse(request: request);
}
