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

  @override
  String toString() {
    return 'HintOneByOneRequest(level: $level, stepByStep: $stepByStep, movesAtRequest: "$movesAtRequest", logLevel: $logLevel)';
  }
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
  final logger = Logger(level: request.logLevel); // logger initialization moved up
  logger.d('Executing HintOneByOne with request: $request'); // Log the request

  final levelList = request.stepByStep ? generateLevelList3Steps(request.level) : [request.level];
  const levelOption = LevelOption();

  for (final level in levelList) {
    edax.edaxStop();
    // logger.d('stopped edax search'); // Replaced by more specific log below
    logger.d('Stopped edax search for level transition.');

    logger.d('Preparing hint for level: $level, movesAtRequest: "${request.movesAtRequest}"');
    edax
      ..edaxSetOption(levelOption.nativeName, level.toString())
      ..edaxHintPrepare();
    // logger.d('prepared getting hint one by one.\nlevel: $level.\nmoves at request: ${request.movesAtRequest}'); // Replaced by more specific log
    logger.d('Hint preparation complete for level: $level.');

    while (true) {
      final currentMoves = edax.edaxGetMoves();
      if (currentMoves != request.movesAtRequest) {
        logger.w( // Changed to warning as this is an abort condition
          'Hint process aborted. currentMoves "$currentMoves" is not equal to movesAtRequest "${request.movesAtRequest}" for level $level.',
        );
        return;
      }

      logger.d(
        'About to call edaxHintNextNoMultiPvDepth. Level: $level, RequestMoves: "${request.movesAtRequest}", CurrentEngineMoves: "$currentMoves"',
      );
      final hint = edax.edaxHintNextNoMultiPvDepth();

      if (hint.isNoMove) {
        logger.d('edaxHintNextNoMultiPvDepth returned NoMove. Ending hint sequence for level $level.');
        break;
      }
      yield HintOneByOneResponse(request: request, hint: hint, level: level, isLastStep: level == levelList.last);
    }
  }
}
