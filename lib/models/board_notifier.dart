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
import '../engine/api/undo.dart';
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

  @override
  void dispose() {
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
      StartEdaxServerParams(_receivePort.sendPort, libedaxPath, initLibedaxParams, _logger),
    );
    _receiveStream = _receivePort.asBroadcastStream();
    _edaxServerPort = await _receiveStream.first as SendPort;
    _logger.d('spawned edax server');

    // ignore: avoid_annotating_with_dynamic
    _receiveStream.listen((final dynamic message) {
      _updateStateByEdaxServerResponse(message);
      notifyListeners();
    });

    value
      ..edaxServerSpawned = true
      ..level = level
      ..hintStepByStep = hintStepByStep
      ..countBestpathAvailability = bestpathCountAvailability;
    notifyListeners();

    requestInit();
  }

  void requestInit() => _edaxServerPort.send(const InitRequest());
  void requestNew() => _edaxServerPort.send(const NewRequest());
  void requestRotate180() => _edaxServerPort.send(const RotateRequest(angle: 180));
  void requestMove(final String move) => _edaxServerPort.send(MoveRequest(move));
  void requestPlay(final String moves) => _edaxServerPort.send(PlayRequest(moves));
  void requestUndo() => _edaxServerPort.send(const UndoRequest(times: 1));
  void requestUndoAll() => _edaxServerPort.send(const UndoRequest(times: 60));
  void requestRedo() => _edaxServerPort.send(const RedoRequest(times: 1));
  void requestRedoAll() => _edaxServerPort.send(const RedoRequest(times: 60));
  void requestSetOption(final String name, final String optionValue) {
    _edaxServerPort.send(SetOptionRequest(name, optionValue));
    if (name == _levelOption.nativeName) value.level = int.parse(optionValue);
  }

  void requestSetboard(final int move) {
    _edaxServerPort.send(
      SetboardRequest(
        currentColor: value.currentColor, // TODO: it is desirable to pass as argument.
        replacementTargets: [SquareReplacement(move, value.arrangeTargetChar)],
        logger: _logger,
      ),
    );
  }

  void finishedNotifyBookHasBeenLoadedToUser() => value.bookLoadStatus = BookLoadStatus.notifiedToUser;

  Future<void> switchHintVisibility() async {
    value
      ..hintsWithStepByStep = UnmodifiableListView([])
      ..hintIsVisible = !value.hintIsVisible;
    notifyListeners();
    if (value.hintIsVisible) _requestLatestHintList(value.currentMoves);
  }

  void switchArrangeTarget(final ArrangeTargetType arrangeTargetType) {
    value.arrangeTargetSquareType = arrangeTargetType;
    notifyListeners();
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
    value.bookLoadStatus = BookLoadStatus.loading;
    notifyListeners();
    _edaxServerPort.send(BookLoadRequest(path));
  }

  void _requestLatestHintList(final String movesAtRequest) {
    value.hintsWithStepByStep = UnmodifiableListView([]);
    if (!value.hintIsVisible) return;
    _edaxServerPort.send(
      HintOneByOneRequest(
        level: value.level,
        stepByStep: value.hintStepByStep,
        movesAtRequest: movesAtRequest,
        logger: _logger,
      ),
    );
  }

  void _requestBookPosition() {
    if (value.bookHasBeenLoaded) {
      _edaxServerPort.send(const GetBookMoveWithPositionRequest());
    }
  }

  Future<void> _requestCountBestpath(final String movesAtRequest) async {
    value.countBestpathList = UnmodifiableListView([]);
    if (!value.hintIsVisible) return;
    if (value.bookHasBeenLoaded) {
      _edaxServerPort.send(
        CountBestpathRequest(
          movesAtRequest: movesAtRequest,
          playerLowerLimit: await _bestpathCountPlayerLowerLimitOption.val,
          opponentLowerLimit: await _bestpathCountOpponentLowerLimitOption.val,
          logger: _logger,
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
      if (message.request.movesAtRequest != value.currentMoves) {
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
          CountBestpathResultWithMove(
            countBestpathList: message.countBestpathResult,
            rootMove: message.rootMove,
          )
        ]);
      }
    } else if (message is BookLoadResponse) {
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
    } else {
      _logger.w('response ${message.runtimeType} is not supported');
    }
  }
}
