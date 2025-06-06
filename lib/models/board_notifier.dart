import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../engine/api/book_get_move_with_position.dart';
import '../engine/api/book_load.dart';
import '../engine/api/count_bestpath.dart';
import '../engine/api/hint_one_by_one.dart';
import '../engine/api/init.dart';
import '../engine/api/move.dart';
import '../engine/api/new.dart';
import '../engine/api/play.dart';
import '../engine/api/redo.dart';
import '../engine/api/rotate.dart';
import '../engine/api/set_option.dart';
import '../engine/api/setboard.dart';
import '../engine/api/stop.dart';
import '../engine/api/undo.dart';
import '../engine/api/shutdown.dart';
import '../engine/edax_server.dart';
import '../engine/options/native/book_file_option.dart';
import '../engine/options/native/level_option.dart';
import '../engine/options/pedax/bestpath_count_opponent_lower_limit.dart';
import '../engine/options/pedax/bestpath_count_player_lower_limit.dart';
import 'board_state.dart';

class BoardNotifier extends ValueNotifier<BoardState> {
  BoardNotifier() : super(BoardState());

  final _logger = Logger();
  late final SendPort _edaxServerPort;
  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;
  final _levelOption = const LevelOption();
  final _bookFileOption = BookFileOption();
  final _bestpathCountPlayerLowerLimitOption = const BestpathCountPlayerLowerLimitOption();
  final _bestpathCountOpponentLowerLimitOption = const BestpathCountOpponentLowerLimitOption();

  Future<void> shutdownEdaxServer() async {
    // _edaxServerPort is late final, so it's guaranteed to be initialized if spawnEdaxServer completed.
    // However, if spawnEdaxServer threw an exception before _edaxServerPort was assigned,
    // this method could be called. Add a check for safety, though ideally,
    // the caller ensures spawnEdaxServer succeeded.
    // A more robust way would be to check a flag set after successful spawn.
    if (value.edaxServerSpawned == false) {
      _logger.i('Edax server not spawned or already shut down, skipping shutdownEdaxServer.');
      return;
    }

    final completer = Completer<void>();
    StreamSubscription<dynamic>? subscription;

    subscription = _receiveStream.listen((message) {
      if (message is ShutdownResponse) {
        _logger.i('Received ShutdownResponse from edax server.');
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription?.cancel(); // Cancel subscription once the desired response is received
      }
    });

    _logger.d('Sending ShutdownRequest to edax server.');
    _edaxServerPort.send(const ShutdownRequest());

    try {
      await completer.future.timeout(const Duration(seconds: 3));
      _logger.i('Edax server shutdown completed.');
    } on TimeoutException {
      _logger.w('Edax server shutdown timed out.');
    } finally {
      await subscription?.cancel(); // Ensure cancellation in all cases (complete, error, timeout)
      // Consider if _edaxServerPort should be nulled or if more aggressive cleanup is needed.
      // For now, we assume the isolate will terminate.
      value.edaxServerSpawned = false; // Mark as shut down
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _logger.d('BoardNotifier dispose called.');
    // It's generally recommended to complete asynchronous operations before disposing.
    // Consider calling shutdownEdaxServer() here or ensuring it's called before dispose.
    // For now, just closing the receive port as per original logic.
    // If shutdownEdaxServer is not called, the isolate might not terminate cleanly.
    _receivePort.close();
    super.dispose();
  }

  Future<void> spawnEdaxServer({
    required final String libedaxPath,
    required final List<String> initLibedaxParams,
    required final int level,
    required final bool hintStepByStep,
    required final bool bestpathCountAvailability,
  }) async {
    await Isolate.spawn(
      startEdaxServer,
      StartEdaxServerParams(_receivePort.sendPort, libedaxPath, initLibedaxParams, Logger.level),
    );
    _receiveStream = _receivePort.asBroadcastStream();
    // It's crucial _edaxServerPort is assigned ONLY after the stream is confirmed to be working.
    final firstMessage = await _receiveStream.first;
    if (firstMessage is SendPort) {
      _edaxServerPort = firstMessage;
      _logger.d('spawned edax server and received SendPort');
    } else {
      _logger.e('Failed to get SendPort from edax server isolate. First message: $firstMessage');
      // Mark as not spawned if we didn't get the SendPort
      value.edaxServerSpawned = false;
      notifyListeners();
      // Propagate the error or handle it more gracefully
      throw Exception('Failed to initialize edax server: SendPort not received.');
    }

    // ignore: avoid_annotating_with_dynamic
    _receiveStream.listen((final dynamic message) {
      if (message is! ShutdownResponse) { // Don't process other messages if we are shutting down
        _updateStateByEdaxServerResponse(message);
        notifyListeners();
      }
    });

    value
      ..edaxServerSpawned = true
      ..level = level
      ..hintStepByStep = hintStepByStep
      ..countBestpathAvailability = bestpathCountAvailability;
    notifyListeners();

    requestInit();
  }

  void requestInit() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const InitRequest());
  }
  void requestNew() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const NewRequest());
  }
  void requestRotate180() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const RotateRequest(angle: 180));
  }
  void requestMove(final String move) {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(MoveRequest(move));
  }
  void requestPlay(final String moves) {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(PlayRequest(moves));
  }
  void requestUndo() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const UndoRequest(times: 1));
  }
  void requestUndoAll() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const UndoRequest(times: 60));
  }
  void requestRedo() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const RedoRequest(times: 1));
  }
  void requestRedoAll() {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const RedoRequest(times: 60));
  }
  void requestSetOption(final String name, final String optionValue) {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(SetOptionRequest(name, optionValue));
    if (name == _levelOption.nativeName) value.level = int.parse(optionValue);
  }

  void requestSetboard(final List<int> replacementTargetMoves) {
    if (!value.edaxServerSpawned) return;
    final arrangeTargetChar = replacementTargetMoves.map((m) => SquareReplacement(m, value.arrangeTargetChar)).toList();
    _edaxServerPort.send(
      SetboardRequest(
        currentColor: value.arrangeTargetColor,
        replacementTargets: arrangeTargetChar,
        logLevel: Logger.level,
      ),
    );
  }

  void finishedNotifyBookHasBeenLoadedToUser() => value.bookLoadStatus = BookLoadStatus.notifiedToUser;

  Future<void> switchHintVisibility() async {
    if (!value.edaxServerSpawned) return;
    _edaxServerPort.send(const StopRequest());
    value
      ..hintIsVisible = !value.hintIsVisible
      ..hintsWithStepByStep = UnmodifiableListView([]);
    notifyListeners();
    if (value.hintIsVisible) _requestLatestHintList(value.currentMoves);
  }

  void switchArrangeTarget(final ArrangeTargetType arrangeTargetType) {
    value.arrangeTargetSquareType = arrangeTargetType;
    notifyListeners();
    requestSetboard([]);
  }

  void switchHintStepByStep({required final bool enabled}) {
    value.hintStepByStep = enabled;
    notifyListeners();
  }

  void switchCountBestpathAvailability({required final bool enabled}) {
    value.countBestpathAvailability = enabled;
    if (!enabled) value.countBestpathList = UnmodifiableListView([]);
  }

  void switchBoardMode(final BoardMode boardMode) {
    value
      ..mode = boardMode
      ..hintsWithStepByStep = UnmodifiableListView([]);
    notifyListeners();
    if (boardMode == BoardMode.freePlay && value.hintIsVisible) _requestLatestHintList(value.currentMoves);
  }

  void requestBookLoad(final String path) {
    if (!value.edaxServerSpawned) return;
    value.bookLoadStatus = BookLoadStatus.loading;
    notifyListeners();
    _edaxServerPort.send(BookLoadRequest(path));
  }

  void _requestLatestHintList(final String movesAtRequest) {
    if (!value.edaxServerSpawned) return;
    value.hintsWithStepByStep = UnmodifiableListView([]);
    if (!value.hintIsVisible) return;
    _edaxServerPort.send(
      HintOneByOneRequest(
        level: value.level,
        stepByStep: value.hintStepByStep,
        movesAtRequest: movesAtRequest,
        logLevel: Logger.level,
      ),
    );
  }

  void _requestBookPosition() {
    if (!value.edaxServerSpawned) return;
    if (value.bookHasBeenLoaded) {
      _edaxServerPort.send(const GetBookMoveWithPositionRequest());
    }
  }

  Future<void> _requestCountBestpath(final String movesAtRequest) async {
    if (!value.edaxServerSpawned) return;
    value.countBestpathList = UnmodifiableListView([]);
    if (!value.hintIsVisible) return;
    if (value.bookHasBeenLoaded) {
      _edaxServerPort.send(
        CountBestpathRequest(
          movesAtRequest: movesAtRequest,
          playerLowerLimit: await _bestpathCountPlayerLowerLimitOption.val,
          opponentLowerLimit: await _bestpathCountOpponentLowerLimitOption.val,
          logLevel: Logger.level,
        ),
      );
    }
  }

  Future<void> _onMovesChanged(final String moves) async {
    _requestBookPosition();
    if (value.mode == BoardMode.freePlay) {
      _requestLatestHintList(moves);
      if (value.countBestpathAvailability) await _requestCountBestpath(moves);
    }
  }

  // ignore: avoid_annotating_with_dynamic
  Future<void> _updateStateByEdaxServerResponse(final dynamic message) async {
    _logger.d('received response "${message.runtimeType}"');
    if (message is MoveResponse) {
      if (value.currentMoves != message.moves) await _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is PlayResponse) {
      if (value.currentMoves != message.moves) await _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is InitResponse) {
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
      if (!value.edaxInitOnce) value.edaxInitOnce = true;
      await _onMovesChanged(message.moves);
    } else if (message is NewResponse) {
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
      await _onMovesChanged(message.moves);
    } else if (message is RotateResponse) {
      await _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is UndoResponse) {
      if (value.currentMoves != message.moves) await _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is RedoResponse) {
      if (value.currentMoves != message.moves) await _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is HintOneByOneResponse) {
      if (message.request.movesAtRequest != value.currentMoves || value.hintIsVisible == false) {
        value.hintsWithStepByStep = UnmodifiableListView([]);
      } else {
        value
          ..hintsWithStepByStep = UnmodifiableListView(
            [...value.hintsWithStepByStep]
              ..removeWhere((final el) => el.hint.move == message.hint.move)
              ..add(HintWithStepByStep(hint: message.hint, isLastStep: message.isLastStep)),
          )
          ..bestScore = value.hintsWithStepByStep.map<int>((final el) => el.hint.score).reduce(max);
      }
    } else if (message is CountBestpathResponse) {
      if (message.request.movesAtRequest != value.currentMoves) {
        value.countBestpathList = UnmodifiableListView([]);
      } else {
        value.countBestpathList = UnmodifiableListView([
          ...value.countBestpathList,
          CountBestpathResultWithMove(countBestpathList: message.countBestpathResult, rootMove: message.rootMove),
        ]);
      }
    } else if (message is BookLoadResponse) {
      _logger.i('book has been loaded.');
      value.bookLoadStatus = BookLoadStatus.loaded;
      await _onMovesChanged(value.currentMoves);
      await _bookFileOption.stopAccessingSecurityScopedResource();
    } else if (message is GetBookMoveWithPositionResponse) {
      value
        ..positionWinsNum = message.position.nWins
        ..positionDrawsNum = message.position.nDraws
        ..positionLossesNum = message.position.nLosses;
    } else if (message is SetboardResponse) {
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is SetOptionResponse) {
      // do nothing
    } else if (message is StopResponse) {
      // do nothing
    } else {
      _logger.w('response ${message.runtimeType} is not supported');
    }
  }
}
