import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';

import 'api/book_get_move_with_position.dart';
import 'api/book_load.dart';
import 'api/hint_one_by_one.dart';
import 'api/init.dart';
import 'api/move.dart';
import 'api/play.dart';
import 'api/redo.dart';
import 'api/rotate.dart';
import 'api/set_option.dart';
import 'api/shutdown.dart';
import 'api/stop.dart';
import 'api/undo.dart';

// NOTE: top level function for `isolate.spawn`.
Future<void> startEdaxServer(StartEdaxServerParams params) async {
  final server = EdaxServer(dllPath: params.dllPath, logger: params.logger);
  await server.start(params.parentSendPort, params.initLibedaxParameters);
}

@immutable
class StartEdaxServerParams {
  const StartEdaxServerParams(this.parentSendPort, this.dllPath, this.initLibedaxParameters, this.logger);
  final SendPort parentSendPort;
  final String dllPath;
  final List<String> initLibedaxParameters;
  final Logger logger;
}

// TODO: consider to separate as edax_server package
@doNotStore
class EdaxServer {
  EdaxServer({required this.dllPath, required this.logger});

  final String dllPath;
  final Logger logger;
  final _receivePort = ReceivePort();

  final _maxSearchWorkerNum = 1;
  int _searchWorkerNum = 0;

  final _maxBookLoadingWorkerNum = 1;
  int _bookLoadingWorkerNum = 0;

  late HintOneByOneRequest _latestHintMessage;

  SendPort get sendPort => _receivePort.sendPort;
  String get serverName => 'EdaxServer';
  Duration get _searchWorkerSpawningSpan => const Duration(milliseconds: 5);

  // NOTE: I want to ensure EdaxServer `isolatable`. So, params depending on platform should be injectable.
  Future<void> start(SendPort parentSendPort, List<String> initLibedaxParameters) async {
    IsolateNameServer.registerPortWithName(sendPort, serverName);

    parentSendPort.send(_receivePort.sendPort); // NOTE: notify my port to parent
    logger.d('sent my port to parentSendPort');

    final edax = LibEdax(dllPath)
      ..libedaxInitialize(initLibedaxParameters)
      ..edaxInit();
    logger.i('libedax has initialized with $initLibedaxParameters');

    // ignore: avoid_annotating_with_dynamic
    _receivePort.listen((dynamic message) async {
      logger.i('received request "${message.runtimeType}"');
      if (message is MoveRequest) {
        parentSendPort.send(executeMove(edax, message));
      } else if (message is PlayRequest) {
        parentSendPort.send(executePlay(edax, message));
      } else if (message is HintOneByOneRequest) {
        _latestHintMessage = message;
        // ignore: literal_only_boolean_expressions
        while (true) {
          if (_searchWorkerNum >= _maxSearchWorkerNum) {
            await Future<void>.delayed(_searchWorkerSpawningSpan);
            continue;
          }
          if (_latestHintMessage.movesAtRequest != message.movesAtRequest) {
            logger.i(
                'The HintOneByOneRequest (moves: ${message.movesAtRequest}) has dropped.\nIt is because a new HintOneByOneRequest (moves: ${_latestHintMessage.movesAtRequest}) has been received after that.');
            break;
          }
          _searchWorkerNum++;
          await compute(_calcHintNext, CalcHintNextParams(dllPath, _latestHintMessage, parentSendPort));
          _searchWorkerNum--;
          break;
        }
      } else if (message is InitRequest) {
        parentSendPort.send(executeInit(edax, message));
      } else if (message is RotateRequest) {
        parentSendPort.send(executeRotate(edax, message));
      } else if (message is UndoRequest) {
        parentSendPort.send(executeUndo(edax, message));
      } else if (message is RedoRequest) {
        parentSendPort.send(executeRedo(edax, message));
      } else if (message is GetBookMoveWithPositionRequest) {
        parentSendPort.send(executeGetBookMoveWithPosition(edax, message));
      } else if (message is BookLoadRequest) {
        logger.i('will load book file. path: ${message.file}');
        if (_bookLoadingWorkerNum >= _maxBookLoadingWorkerNum) return;
        _bookLoadingWorkerNum++;
        await compute(_execBookLoad, BookLoadParams(dllPath, message, parentSendPort));
        _bookLoadingWorkerNum--;
      } else if (message is SetOptionRequest) {
        parentSendPort.send(executeSetOption(edax, message));
      } else if (message is StopRequest) {
        parentSendPort.send(executeStop(edax, message));
      } else if (message is ShutdownRequest) {
        parentSendPort.send(executeShutdown(edax, message));
        _receivePort.close();
        logger.i('shutdowned');
      } else {
        logger.w('request ${message.runtimeType} is not supported');
      }
    }); // TODO: error handling
  }
}

@immutable
class CalcHintNextParams {
  const CalcHintNextParams(this.dllPath, this.request, this.listener);
  final String dllPath;
  final HintOneByOneRequest request;
  final SendPort listener;
}

// NOTE: top level function for `compute`.
Future<void> _calcHintNext(CalcHintNextParams params) async {
  final edax = LibEdax(params.dllPath);
  await executeHintOneByOne(edax, params.request).listen(params.listener.send).asFuture<void>();
}

@immutable
class BookLoadParams {
  const BookLoadParams(this.dllPath, this.request, this.listener);
  final String dllPath;
  final BookLoadRequest request;
  final SendPort listener;
}

// NOTE: top level function for `compute`.
void _execBookLoad(BookLoadParams params) {
  final edax = LibEdax(params.dllPath);
  final result = executeBookLoad(edax, params.request);
  params.listener.send(result);
}
