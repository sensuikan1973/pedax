import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

@immutable
class HintOneByOneRequest implements RequestSchema {
  const HintOneByOneRequest({
    required final this.level,
    required final this.stepByStep,
    required final this.movesAtRequest,
    required final this.logger,
  });

  final int level;
  final bool stepByStep;
  final String movesAtRequest;
  final Logger logger;
}

@immutable
class HintOneByOneResponse implements ResponseSchema<HintOneByOneRequest> {
  const HintOneByOneResponse({
    required final this.hint,
    required final this.level,
    required final this.request,
  });

  @override
  final HintOneByOneRequest request;
  final Hint hint;
  final int level;
}

@visibleForTesting
List<int> generateLevelList3Steps(final int maxLevel) =>
    [(maxLevel / 3).floor(), (maxLevel / 1.5).floor(), maxLevel]..sort();

Stream<HintOneByOneResponse> executeHintOneByOne(
  final LibEdax edax,
  final HintOneByOneRequest request,
) async* {
  final levelList = request.stepByStep ? generateLevelList3Steps(request.level) : [request.level];
  for (final level in levelList) {
    edax.edaxStop();
    request.logger.d('stopped edax serach');
    edax
      ..edaxSetOption('-level', level.toString())
      ..edaxHintPrepare();
    request.logger.d('prepared getting hint one by one.\nlevel: $level.\nmoves at request: ${request.movesAtRequest}');
    // ignore: literal_only_boolean_expressions
    while (true) {
      final currentMoves = edax.edaxGetMoves();
      if (currentMoves != request.movesAtRequest) {
        request.logger.d(
          'hint process is aborted.\ncurrentMoves "$currentMoves" is not equal to movesAtRequest "${request.movesAtRequest}"',
        );
        return;
      }

      request.logger.d('will call edaxHintNextNoMultiPvDepth');
      final hint = edax.edaxHintNextNoMultiPvDepth();
      if (hint.isNoMove) break;
      yield HintOneByOneResponse(hint: hint, level: level, request: request);
    }
  }
}
