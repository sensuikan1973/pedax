import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import '../options/native/level_option.dart';
import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class HintOneByOneRequest implements RequestSchema {
  const HintOneByOneRequest({
    required this.level,
    required this.stepByStep,
    required this.movesAtRequest,
    required this.logLevel,
  });

  final int level;
  final bool stepByStep;
  final String movesAtRequest;
  final Level logLevel;
}

@immutable
class HintOneByOneResponse implements ResponseSchema<HintOneByOneRequest> {
  const HintOneByOneResponse({
    required this.request,
    required this.hint,
    required this.level,
    required this.isLastStep,
  });

  @override
  final HintOneByOneRequest request;
  final Hint hint;
  final int level;
  final bool isLastStep;
}

@visibleForTesting
List<int> generateLevelList3Steps(final int maxLevel) =>
    [(maxLevel / 3).floor(), (maxLevel / 1.5).floor(), maxLevel]..sort();

Stream<HintOneByOneResponse> executeHintOneByOne(final LibEdax edax, final HintOneByOneRequest request) async* {
  final levelList = request.stepByStep ? generateLevelList3Steps(request.level) : [request.level];
  const levelOption = LevelOption();
  final logger = Logger(level: request.logLevel);
  for (final level in levelList) {
    edax.edaxStop();
    logger.d('stopped edax search');
    edax
      ..edaxSetOption(levelOption.nativeName, level.toString())
      ..edaxHintPrepare();
    logger.d('prepared getting hint one by one.\nlevel: $level.\nmoves at request: ${request.movesAtRequest}');
    while (true) {
      final currentMoves = edax.edaxGetMoves();
      if (currentMoves != request.movesAtRequest) {
        logger.d(
          'hint process is aborted.\ncurrentMoves "$currentMoves" is not equal to movesAtRequest "${request.movesAtRequest}"',
        );
        return;
      }

      logger.d('will call edaxHintNextNoMultiPvDepth');
      final hint = edax.edaxHintNextNoMultiPvDepth();
      if (hint.isNoMove) break;
      yield HintOneByOneResponse(request: request, hint: hint, level: level, isLastStep: level == levelList.last);
    }
  }
}
