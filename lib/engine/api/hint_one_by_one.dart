import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

final _logger = Logger();

@immutable
class HintOneByOneRequest extends RequestSchema {
  const HintOneByOneRequest({required this.level, required this.stepByStep});

  final int level;
  final bool stepByStep;

  @override
  String get name => 'hintOneByOne';
}

@immutable
class HintOneByOneResponse extends ResponseSchema<HintOneByOneRequest> {
  const HintOneByOneResponse({
    required this.hint,
    required this.searchTargetMoves,
    required this.level,
    required HintOneByOneRequest request,
  }) : super(request);

  final Hint hint;
  final String searchTargetMoves;
  final int level;
}

@visibleForTesting
List<int> generateLevelList3Steps(int maxLevel) => [1, (maxLevel / 3).floor(), maxLevel];

Stream<HintOneByOneResponse> executeHintOneByOne(LibEdax edax, HintOneByOneRequest request) async* {
  edax.edaxStop();
  _logger.d('stopped edax serach');

  final levelList = request.stepByStep ? [request.level] : generateLevelList3Steps(request.level);
  for (final level in levelList) {
    final currentMoves = edax.edaxGetMoves();
    _logger.d('current moves: $currentMoves');
    edax
      ..edaxSetOption('-level', level.toString())
      ..edaxHintPrepare();
    _logger.d('prepared getting hint one by one. level: $level.');
    // ignore: literal_only_boolean_expressions
    while (true) {
      sleep(const Duration(milliseconds: 10));
      if (edax.edaxGetMoves() != currentMoves) break;

      _logger.d('will call edaxHintNextNoMultiPvDepth');
      final hint = edax.edaxHintNextNoMultiPvDepth();
      _logger.d('${hint.moveString}: ${hint.scoreString}');
      if (hint.isNoMove) break;
      yield HintOneByOneResponse(hint: hint, searchTargetMoves: currentMoves, level: level, request: request);
    }
  }
}
