import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import '../engine/api/book_get_move_with_position.dart';
import '../engine/api/book_load.dart';
import '../engine/api/hint_one_by_one.dart';
import '../engine/api/init.dart';
import '../engine/api/move.dart';
import '../engine/api/play.dart';
import '../engine/api/redo.dart';
import '../engine/api/undo.dart';
import '../engine/edax_server.dart';
import 'board_state.dart';

@doNotStore
class BoardNotifier extends ValueNotifier<BoardState> {
  BoardNotifier() : super(BoardState());

  final _logger = Logger();
  final Completer<bool> _edaxServerSpawned = Completer<bool>();
  late final SendPort _edaxServerPort;
  final _receivePort = ReceivePort();
  late final Stream<dynamic> _receiveStream;

  Future<void> spawnEdaxServer({
    required String libedaxPath,
    required List<String> initLibedaxParams,
    required int level,
    required bool hintStepByStep,
  }) async {
    await Isolate.spawn(
      startEdaxServer,
      StartEdaxServerParams(_receivePort.sendPort, libedaxPath, initLibedaxParams),
    );
    _receiveStream = _receivePort.asBroadcastStream();
    _edaxServerPort = await _receiveStream.first as SendPort;
    _edaxServerSpawned.complete(true);
    _logger.d('spawned edax server');

    _receiveStream.listen(_updateStateByEdaxServerResponse);
    _edaxServerPort.send(const InitRequest());

    value
      ..level = level
      ..hintStepByStep = hintStepByStep;
  }

  void requestInit() => _edaxServerPort.send(const InitRequest());
  void requestMove(String move) => _edaxServerPort.send(MoveRequest(move));
  void requestPlay(String moves) => _edaxServerPort.send(PlayRequest(moves));
  void requestUndo() => _edaxServerPort.send(const UndoRequest(times: 1));
  void requestUndoAll() => _edaxServerPort.send(const UndoRequest(times: 60));
  void requestRedo() => _edaxServerPort.send(const RedoRequest(times: 1));
  void requestRedoAll() => _edaxServerPort.send(const RedoRequest(times: 60));

  Future<void> switchHintVisibility() async {
    value.hints.clear();
    value.hintIsVisible = !value.hintIsVisible;
    if (value.hintIsVisible) _edaxServerPort.send(await _buildHintRequest(value.currentMoves));
  }

  void requestBookLoad(String path) {
    value.bookLoading = true;
    _edaxServerPort.send(BookLoadRequest(path));
  }

  Future<HintOneByOneRequest> _buildHintRequest(String movesAtRequest) async => HintOneByOneRequest(
        level: value.level,
        stepByStep: value.hintStepByStep,
        movesAtRequest: movesAtRequest,
      );

  Future<void> _onMovesUpdated(String moves) async {
    value.hints.clear();
    if (value.hintIsVisible) _edaxServerPort.send(await _buildHintRequest(moves));
    if (!value.bookLoading) _edaxServerPort.send(const GetBookMoveWithPositionRequest());
  }

  // ignore: avoid_annotating_with_dynamic
  Future<void> _updateStateByEdaxServerResponse(dynamic message) async {
    _logger.i('received response "${message.runtimeType}"');
    if (message is MoveResponse) {
      if (value.currentMoves != message.moves) await _onMovesUpdated(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = value.board.squaresOfPlayer
        ..squaresOfOpponent = value.board.squaresOfOpponent
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is PlayResponse) {
      if (value.currentMoves != message.moves) await _onMovesUpdated(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = value.board.squaresOfPlayer
        ..squaresOfOpponent = value.board.squaresOfOpponent
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is InitResponse) {
      if (!value.edaxInit.isCompleted) value.edaxInit.complete(true);
      await _onMovesUpdated(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = value.board.squaresOfPlayer
        ..squaresOfOpponent = value.board.squaresOfOpponent
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is UndoResponse) {
      if (value.currentMoves != message.moves) await _onMovesUpdated(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = value.board.squaresOfPlayer
        ..squaresOfOpponent = value.board.squaresOfOpponent
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is RedoResponse) {
      if (value.currentMoves != message.moves) await _onMovesUpdated(message.moves);
      value
        ..board = message.board
        ..squaresOfPlayer = value.board.squaresOfPlayer
        ..squaresOfOpponent = value.board.squaresOfOpponent
        ..currentColor = message.currentColor
        ..lastMove = message.lastMove
        ..currentMoves = message.moves;
    } else if (message is HintOneByOneResponse) {
      _logger.d('${message.hint.moveString}: ${message.hint.scoreString}');
      if (message.request.movesAtRequest != value.currentMoves) return value.hints.clear();
      value.hints
        ..removeWhere((hint) => hint.move == message.hint.move)
        ..add(message.hint);
      value.bestScore = value.hints.map<int>((h) => h.score).reduce(max);
    } else if (message is BookLoadResponse) {
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(AppLocalizations.of(context)!.finishedLoadingBookFile, textAlign: TextAlign.center),
      //   ),
      // );
      value.bookLoading = false;
    } else if (message is GetBookMoveWithPositionResponse) {
      value
        ..positionWinsNum = message.position.nWins
        ..positionDrawsNum = message.position.nDraws
        ..positionLossesNum = message.position.nLosses;
    }
  }
}
