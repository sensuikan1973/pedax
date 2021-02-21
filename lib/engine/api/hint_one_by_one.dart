import 'dart:io';

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
    required this.searchTargetMoves,
    required HintOneByOneRequest request,
  }) : super(request);

  final Hint hint;
  final String searchTargetMoves;
}

Stream<HintOneByOneResponse> executeHintOneByOne(LibEdax edax, HintOneByOneRequest request) async* {
  edax.edaxStop();
  debugPrint('[executeHintOneByOne]: stopped');
  final currentMoves = edax.edaxGetMoves();
  debugPrint('[executeHintOneByOne]: currentMoves is $currentMoves');
  edax.edaxHintPrepare();
  debugPrint('[executeHintOneByOne]: prepared');
  // ignore: literal_only_boolean_expressions
  while (true) {
    sleep(const Duration(milliseconds: 10));
    if (edax.edaxGetMoves() != currentMoves) break;

    debugPrint('[executeHintOneByOne] will call edaxHintNextNoMultiPvDepth');
    final hint = edax.edaxHintNextNoMultiPvDepth();
    debugPrint('[executeHintOneByOne] ${hint.moveString}: ${hint.scoreString}');
    if (hint.isNoMove) break;
    yield HintOneByOneResponse(hint: hint, searchTargetMoves: currentMoves, request: request);
  }
}
