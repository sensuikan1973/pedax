import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart'; // For TurnColor, ColorChar, LibEdax, Board, Move
import 'package:logger/logger.dart';

import 'request_schema.dart';
import 'response_schema.dart';

// The SquareReplacement class should be removed from this file as it's no longer used by SetboardRequest.
// (Assuming no other code directly imports SquareReplacement from this specific file path).

@immutable
class SetboardRequest implements RequestSchema {
  const SetboardRequest({
    required this.boardChars, // 64 characters representing the board
    required this.currentColor, // int: TurnColor.black or TurnColor.white
    required this.logLevel,
  });

  final String boardChars;
  final int currentColor;
  final Level logLevel;
}

@immutable
class SetboardResponse implements ResponseSchema<SetboardRequest> {
  const SetboardResponse({
    required this.board,
    required this.currentColor,
    required this.moves,
    required this.lastMove,
    required this.request,
  });

  @override
  final SetboardRequest request;
  final Board board;
  final int currentColor;
  final String moves;
  final Move? lastMove;
}

SetboardResponse executeSetboard(final LibEdax edax, final SetboardRequest request) {
  edax.edaxStop(); // Existing behavior

  // Validate boardChars length. Robust validation should ideally be done by the caller.
  if (request.boardChars.length != 64) {
    final logger = Logger(level: request.logLevel);
    logger.e('Error: boardChars length in SetboardRequest is not 64. Actual: ${request.boardChars.length}');
    // This is a programming error if it happens. Consider throwing an ArgumentError.
    // For now, to prevent crashing the edax server, we might return an error state or
    // an "empty" board, though throwing is often better for contract violations.
    // However, edax.edaxSetboard might also crash if given a malformed string.
    // Let's assume the caller (BoardNotifier) ensures this.
  }

  // Convert currentColor (int) to its character representation.
  // ColorChar.black is 'X', ColorChar.white is 'O'.
  final String playerChar = (request.currentColor == TurnColor.black) ? ColorChar.black : ColorChar.white;
  
  final String fullBoardString = request.boardChars + playerChar;

  final logger = Logger(level: request.logLevel);
  logger.d('setboard $fullBoardString'); // Log the full 65-char string being sent to edax
  edax.edaxSetboard(fullBoardString);

  return SetboardResponse(
    board: edax.edaxGetBoard(),
    currentColor: edax.edaxGetCurrentPlayer(),
    moves: edax.edaxGetMoves(),
    lastMove: edax.edaxGetLastMove(),
    request: request,
  );
}
