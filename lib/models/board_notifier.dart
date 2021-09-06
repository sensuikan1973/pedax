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
import '../engine/api/play.dart';
import '../engine/api/redo.dart';
import '../engine/api/rotate.dart';
import '../engine/api/set_option.dart';
import '../engine/api/undo.dart';
import '../engine/edax_server.dart';
import '../engine/options/book_file_option.dart';
import '../engine/options/level_option.dart';
import 'board_state.dart';

class BoardNotifier extends ValueNotifier<BoardState> {
  BoardNotifier() : super(BoardState());

  final _logger = Logger();
  late final SendPort _edaxServerPort;
  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;
  final _levelOption = const LevelOption();
  final _bookFileOption = const BookFileOption();

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

  void finishedNotifyingBookHasLoadedToUser() {
    value.bookLoadStatus = BookLoadStatus.notifiedToUser;
    // notifyListeners();
  }

  Future<void> switchHintVisibility() async {
    value
      ..hints = UnmodifiableListView([])
      ..hintIsVisible = !value.hintIsVisible;
    notifyListeners();
    if (value.hintIsVisible) _edaxServerPort.send(_buildHintRequest(value.currentMoves));
  }

  // ignore: use_setters_to_change_properties
  void switchHintStepByStep({required final bool enabled}) => value.hintStepByStep = enabled;

  void switchCountBestpathAvailability({required final bool enabled}) {
    value.countBestpathAvailability = enabled;
    if (!enabled) value.countBestpathList = UnmodifiableListView([]);
  }

  void requestBookLoad(final String path) {
    value.bookLoadStatus = BookLoadStatus.loading;
    notifyListeners();
    _edaxServerPort.send(BookLoadRequest(path));
  }

  HintOneByOneRequest _buildHintRequest(final String movesAtRequest) => HintOneByOneRequest(
        level: value.level,
        stepByStep: value.hintStepByStep,
        movesAtRequest: movesAtRequest,
        logger: _logger,
      );

  void _requestLatestHintList(final String movesAtRequest) {
    value.hints = UnmodifiableListView([]);
    if (value.hintIsVisible) _edaxServerPort.send(_buildHintRequest(movesAtRequest));
    if (value.bookLoadStatus == BookLoadStatus.loaded || value.bookLoadStatus == BookLoadStatus.notifiedToUser) {
      _edaxServerPort.send(const GetBookMoveWithPositionRequest());
    }
  }

  void _requestCountBestpath(final String movesAtRequest) {
    value.countBestpathList = UnmodifiableListView([]);
    if (!value.hintIsVisible) return;
    if (value.bookLoadStatus == BookLoadStatus.loaded || value.bookLoadStatus == BookLoadStatus.notifiedToUser) {
      _edaxServerPort.send(CountBestpathRequest(movesAtRequest: movesAtRequest, logger: _logger));
    }
  }

  void _onMovesChanged(final String moves) {
    _requestLatestHintList(moves);
    if (value.countBestpathAvailability) _requestCountBestpath(moves);
  }

  // ignore: avoid_annotating_with_dynamic
  Future<void> _updateStateByEdaxServerResponse(final dynamic message) async {
    _logger.d('received response "${message.runtimeType}"');
    if (message is MoveResponse) {
      if (value.currentMoves != message.moves) _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is PlayResponse) {
      if (value.currentMoves != message.moves) _onMovesChanged(message.moves);
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
      _onMovesChanged(message.moves);
    } else if (message is RotateResponse) {
      _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is UndoResponse) {
      if (value.currentMoves != message.moves) _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is RedoResponse) {
      if (value.currentMoves != message.moves) _onMovesChanged(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = UnmodifiableListView(message.board.squaresOfPlayer)
        ..squaresOfOpponent = UnmodifiableListView(message.board.squaresOfOpponent)
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is HintOneByOneResponse) {
      if (message.request.movesAtRequest != value.currentMoves) {
        value.hints = UnmodifiableListView([]);
      } else {
        value
          ..hints = UnmodifiableListView(
            [...value.hints]
              ..removeWhere((final hint) => hint.move == message.hint.move)
              ..add(message.hint),
          )
          ..bestScore = value.hints.map<int>((final h) => h.score).reduce(max);
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
      _onMovesChanged(value.currentMoves);
      await _bookFileOption.stopAccessingSecurityScopedResource();
    } else if (message is GetBookMoveWithPositionResponse) {
      value
        ..positionWinsNum = message.position.nWins
        ..positionDrawsNum = message.position.nDraws
        ..positionLossesNum = message.position.nLosses;
    } else if (message is SetOptionResponse) {
      // do nothing
    } else {
      _logger.w('response ${message.runtimeType} is not supported');
    }
  }
}
