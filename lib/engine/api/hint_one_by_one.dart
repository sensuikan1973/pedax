import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class HintOneByOneRequest extends RequestSchema {
  const HintOneByOneRequest();

  @override
  String get name => 'hintOneByOne';
}

@immutable
class HintOneByOneResponse extends ResponseSchema<HintOneByOneRequest> {
  const HintOneByOneResponse({
    required this.hint,
    required HintOneByOneRequest request,
  }) : super(request);

  final Hint hint;
}

Stream<HintOneByOneResponse> executeHintOneByOne(LibEdax edax, HintOneByOneRequest request) async* {
  edax
    ..edaxStop()
    ..edaxHintPrepare();
  // ignore: literal_only_boolean_expressions
  while (true) {
    final hint = edax.edaxHintNextNoMultiPvDepth();
    debugPrint('${hint.moveString}: ${hint.scoreString}');
    if (hint.isNoMove) break;
    yield HintOneByOneResponse(hint: hint, request: request);
  }
}
