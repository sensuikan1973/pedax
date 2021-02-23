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
List<int> generateLevelList3Steps(int maxLevel) => [(maxLevel / 3).floor(), (maxLevel / 1.5).floor(), maxLevel]..sort();

Stream<HintOneByOneResponse> executeHintOneByOne(LibEdax edax, HintOneByOneRequest request) async* {
  final levelList = request.stepByStep ? generateLevelList3Steps(request.level) : [request.level];
  for (final level in levelList) {
    edax.edaxStop();
    _logger.d('stopped edax serach');
    final currentMoves = edax.edaxGetMoves();
    edax
      ..edaxSetOption('-level', level.toString())
      ..edaxHintPrepare();
    _logger.d('prepared getting hint one by one.\nlevel: $level.\ncurrent moves: $currentMoves');
    // ignore: literal_only_boolean_expressions
    while (true) {
      if (edax.edaxGetMoves() != currentMoves) break;

      _logger.d('will call edaxHintNextNoMultiPvDepth');
      final hint = edax.edaxHintNextNoMultiPvDepth();
      _logger.d('${hint.moveString}: ${hint.scoreString}');
      if (hint.isNoMove) break;
      yield HintOneByOneResponse(hint: hint, searchTargetMoves: currentMoves, level: level, request: request);
    }
  }
}
