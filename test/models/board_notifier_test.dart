import 'package:flutter_test/flutter_test.dart';
import 'package:pedax/models/board_notifier.dart';
import 'package:pedax/models/board_state.dart'; // For BoardMode
import 'package:pedax/engine/api/setboard.dart'; // For SetboardRequest
// import 'package:pedax/engine/edax_server.dart'; // For StartEdaxServerParams, if needed for setup
import 'package:libedax4dart/libedax4dart.dart'; // For TurnColor
import 'package:mocktail/mocktail.dart';
import 'dart:async'; // For StreamController, SendPort
import 'package:logger/logger.dart'; // For Logger.level

// Mocks
// Mock SendPort to verify that messages are sent
class MockSendPort extends Mock implements SendPort {}

void main() {
  late BoardNotifier boardNotifier;
  late MockSendPort mockEdaxServerPort;

  setUp(() async {
    boardNotifier = BoardNotifier();
    mockEdaxServerPort = MockSendPort();

    // Bypass spawnEdaxServer and directly set the port and necessary state
    // This is a simplified setup for unit testing BoardNotifier methods.
    // A more complete setup might involve mocking the Isolate and Stream.
    boardNotifier.testerSetEdaxServerPort(mockEdaxServerPort); // Needs a test-only setter
    
    // Initialize some default state values if methods rely on them
    boardNotifier.value.mode = BoardMode.freePlay; // Default mode
    // It's good practice to set a specific logger level for tests
    // to avoid unexpected console output and ensure consistency.
    Logger.level = Level.error; // Suppress logs during tests unless needed
  });

  group('BoardNotifier', () {
    group('requestSetBoardFromString', () {
      test('sends SetboardRequest with correct parameters for valid X turn string', () {
        const positionString = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX X';
        // Expected: 64 'X's, Black to move
        
        boardNotifier.requestSetBoardFromString(positionString);
        
        final expectedBoardChars = 'X' * 64;
        final expectedCurrentColor = TurnColor.black;

        verify(() => mockEdaxServerPort.send(any<SetboardRequest>(
          that: predicate<SetboardRequest>((req) {
            return req.boardChars == expectedBoardChars &&
                   req.currentColor == expectedCurrentColor;
          }),
        ))).called(1);
      });

      test('sends SetboardRequest with correct parameters for valid O turn string', () {
        const positionString = '---------------------------------------------------------------- O';
        // Expected: 64 '-'s, White to move

        boardNotifier.requestSetBoardFromString(positionString);

        final expectedBoardChars = '-' * 64;
        final expectedCurrentColor = TurnColor.white;

        verify(() => mockEdaxServerPort.send(any<SetboardRequest>(
          that: predicate<SetboardRequest>((req) {
            return req.boardChars == expectedBoardChars &&
                   req.currentColor == expectedCurrentColor;
          }),
        ))).called(1);
      });

      test('does not send if string length is invalid', () {
        const invalidString = 'short';
        boardNotifier.requestSetBoardFromString(invalidString);
        verifyNever(() => mockEdaxServerPort.send(any()));
      });

      test('does not send if player turn char is invalid', () {
        const invalidPlayerString = '---------------------------------------------------------------- Z';
        boardNotifier.requestSetBoardFromString(invalidPlayerString);
        verifyNever(() => mockEdaxServerPort.send(any()));
      });

      test('switches to BoardMode.freePlay if currently in arrangeDiscs mode', () {
        boardNotifier.value.mode = BoardMode.arrangeDiscs;
        const positionString = '---------------------------------------------------------------- X';
        
        boardNotifier.requestSetBoardFromString(positionString);
        
        expect(boardNotifier.value.mode, BoardMode.freePlay);
        // Also verify SetboardRequest is sent
        verify(() => mockEdaxServerPort.send(any<SetboardRequest>())).called(1);
      });
    });

    // Add tests for the refactored requestSetboard (arrange discs) if time permits
    // This would be more complex as it relies on value.board.string()
    // For now, focusing on requestSetBoardFromString
  });
}

// The test-only setter in BoardNotifier class was added in a previous step:
// class BoardNotifier extends ValueNotifier<BoardState> {
//   ...
//   @visibleForTesting
//   void testerSetEdaxServerPort(SendPort port) {
//     _edaxServerPort = port;
//   }
//   ...
// }
