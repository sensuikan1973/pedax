import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import 'api/book_get_move_with_position.dart';
import 'api/book_load.dart';
import 'api/count_bestpath.dart';
import 'api/hint_one_by_one.dart';
import 'api/init.dart';
import 'api/move.dart';
import 'api/new.dart';
import 'api/play.dart';
import 'api/redo.dart';
import 'api/rotate.dart';
import 'api/set_option.dart';
import 'api/setboard.dart';
import 'api/shutdown.dart';
import 'api/stop.dart';
import 'api/undo.dart';

// NOTE: top level function for `isolate.spawn`.
@doNotStore
Future<void> startEdaxServer(final StartEdaxServerParams params) async {
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

@doNotStore
class EdaxServer {
  EdaxServer({
    required final String dllPath,
    required final Logger logger,
  })  : _dllPath = dllPath,
        _logger = logger;

  final String _dllPath;
  final Logger _logger;

  final _receivePort = ReceivePort();
  SendPort get sendPort => _receivePort.sendPort;
  String get serverName => 'EdaxServer';

  bool _computingBookLoading = false;
  bool _computingHintOneByOne = false;
  late HintOneByOneRequest _latestHintntOneByOneRequest;
  bool _computingCountBestpath = false;
  late CountBestpathRequest _latestCountBestpathRequest;

  // NOTE: I want to ensure EdaxServer `isolatable`. So, params depending on platform should be injectable.
  Future<void> start(final SendPort parentSendPort, final List<String> initLibedaxParameters) async {
    IsolateNameServer.registerPortWithName(sendPort, serverName);

    parentSendPort.send(_receivePort.sendPort); // NOTE: notify my port to parent
    _logger.d('sent my port to parentSendPort');

    final edax = LibEdax(_dllPath)
      ..libedaxInitialize(initLibedaxParameters)
      ..edaxInit();
    _logger.i('libedax has initialized with $initLibedaxParameters');

    _registerApiHandler(parentSendPort, edax);
  }

  void _registerApiHandler(final SendPort parentSendPort, final LibEdax edax) =>
      // ignore: avoid_annotating_with_dynamic
      _receivePort.listen((final dynamic message) async {
        _logger.d('received request "${message.runtimeType}"');
        if (message is MoveRequest) {
          parentSendPort.send(executeMove(edax, message));
        } else if (message is PlayRequest) {
          parentSendPort.send(executePlay(edax, message));
        } else if (message is HintOneByOneRequest) {
          _latestHintntOneByOneRequest = message;
          while (true) {
            if (_computingHintOneByOne) {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              continue;
            }
            if (_latestHintntOneByOneRequest.movesAtRequest != message.movesAtRequest) {
              _logger.d(
                '''
              The HintOneByOneRequest (moves: ${message.movesAtRequest}) has dropped.
              It is because a new HintOneByOneRequest (moves: ${_latestHintntOneByOneRequest.movesAtRequest}) has been received after that.
              ''',
              );
              break;
            }
            _computingHintOneByOne = true;
            await compute(
              _computeHintNext,
              _ComputeHintNextParams(_dllPath, _latestHintntOneByOneRequest, parentSendPort),
            );
            _computingHintOneByOne = false;
            break;
          }
        } else if (message is InitRequest) {
          parentSendPort.send(executeInit(edax, message));
        } else if (message is NewRequest) {
          parentSendPort.send(executeNew(edax, message));
        } else if (message is RotateRequest) {
          parentSendPort.send(executeRotate(edax, message));
        } else if (message is UndoRequest) {
          parentSendPort.send(executeUndo(edax, message));
        } else if (message is RedoRequest) {
          parentSendPort.send(executeRedo(edax, message));
        } else if (message is GetBookMoveWithPositionRequest) {
          parentSendPort.send(executeGetBookMoveWithPosition(edax, message));
        } else if (message is CountBestpathRequest) {
          _latestCountBestpathRequest = message;
          while (true) {
            if (_computingCountBestpath) {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              continue;
            }
            if (_latestCountBestpathRequest.movesAtRequest != message.movesAtRequest) {
              _logger.d(
                '''
              The CountBestpathRequest (moves: ${message.movesAtRequest}) has dropped.
              It is because a new CountBestpathRequest (moves: ${_latestCountBestpathRequest.movesAtRequest}) has been received after that.
              ''',
              );
              break;
            }
            _computingCountBestpath = true;
            await compute(
              _computeCountBestpath,
              _ComputeCountBestpathParams(
                _dllPath,
                _latestCountBestpathRequest,
                parentSendPort,
              ),
            );
            _computingCountBestpath = false;
            break;
          }
        } else if (message is BookLoadRequest) {
          if (_computingBookLoading) return;
          _computingBookLoading = true;
          _logger.i('will load book file. path: ${message.file}');
          await compute(_computeBookLoad, _ComputeBookLoadParams(_dllPath, message, parentSendPort));
          _computingBookLoading = false;
        } else if (message is SetOptionRequest) {
          parentSendPort.send(executeSetOption(edax, message));
        } else if (message is SetboardRequest) {
          parentSendPort.send(executeSetboard(edax, message));
        } else if (message is StopRequest) {
          parentSendPort.send(executeStop(edax, message));
        } else if (message is ShutdownRequest) {
          parentSendPort.send(executeShutdown(edax, message));
          _receivePort.close();
          _logger.i('shutdowned');
        } else {
          _logger.w('request ${message.runtimeType} is not supported');
        }
      });
}

@immutable
class _ComputeHintNextParams {
  const _ComputeHintNextParams(this.dllPath, this.request, this.listener);
  final String dllPath;
  final HintOneByOneRequest request;
  final SendPort listener;
}

// NOTE: top level function for `compute`.
@doNotStore
Future<void> _computeHintNext(final _ComputeHintNextParams params) async {
  final edax = LibEdax(params.dllPath);
  await executeHintOneByOne(edax, params.request).listen(params.listener.send).asFuture<void>();
}

@immutable
class _ComputeBookLoadParams {
  const _ComputeBookLoadParams(this.dllPath, this.request, this.listener);
  final String dllPath;
  final BookLoadRequest request;
  final SendPort listener;
}

// NOTE: top level function for `compute`.
@doNotStore
void _computeBookLoad(final _ComputeBookLoadParams params) {
  final edax = LibEdax(params.dllPath);
  final result = executeBookLoad(edax, params.request);
  params.listener.send(result);
}

@immutable
class _ComputeCountBestpathParams {
  const _ComputeCountBestpathParams(this.dllPath, this.request, this.listener);
  final String dllPath;
  final CountBestpathRequest request;
  final SendPort listener;
}

// NOTE: top level function for `compute`.
@doNotStore
Future<void> _computeCountBestpath(final _ComputeCountBestpathParams params) async {
  final edax = LibEdax(params.dllPath);
  await executeCountBestpath(edax, params.request).listen(params.listener.send).asFuture<void>();
}
