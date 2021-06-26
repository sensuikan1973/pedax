import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

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
import 'api/stream_of_best_path_num_with_link.dart';
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

// TODO: consider to separate as a package
@doNotStore
class EdaxServer {
  EdaxServer({required final this.dllPath, required final this.logger});

  final String dllPath;
  final Logger logger;
  final _receivePort = ReceivePort();
  SendPort get sendPort => _receivePort.sendPort;
  String get serverName => 'EdaxServer';

  bool _computingBookLoading = false;
  bool _computingHintOneByOne = false;
  late HintOneByOneRequest _latestHintntOneByOneRequest;
  bool _computingStreamOfBestPathNumWithLink = false;
  late StreamOfBestPathNumWithLinkRequest _latestStreamOfBestPathNumWithLinkRequest;

  // NOTE: I want to ensure EdaxServer `isolatable`. So, params depending on platform should be injectable.
  Future<void> start(final SendPort parentSendPort, final List<String> initLibedaxParameters) async {
    IsolateNameServer.registerPortWithName(sendPort, serverName);

    parentSendPort.send(_receivePort.sendPort); // NOTE: notify my port to parent
    logger.d('sent my port to parentSendPort');

    final edax = LibEdax(dllPath)
      ..libedaxInitialize(initLibedaxParameters)
      ..edaxInit();
    logger.i('libedax has initialized with $initLibedaxParameters');

    _registerApiHandler(parentSendPort, edax);
  }

  void _registerApiHandler(final SendPort parentSendPort, final LibEdax edax) =>
      // ignore: avoid_annotating_with_dynamic
      _receivePort.listen((final dynamic message) async {
        logger.d('received request "${message.runtimeType}"');
        if (message is MoveRequest) {
          parentSendPort.send(executeMove(edax, message));
        } else if (message is PlayRequest) {
          parentSendPort.send(executePlay(edax, message));
        } else if (message is HintOneByOneRequest) {
          _latestHintntOneByOneRequest = message;
          // ignore: literal_only_boolean_expressions
          while (true) {
            if (_computingHintOneByOne) {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              continue;
            }
            if (_latestHintntOneByOneRequest.movesAtRequest != message.movesAtRequest) {
              logger.d(
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
              _ComputeHintNextParams(dllPath, _latestHintntOneByOneRequest, parentSendPort),
            );
            _computingHintOneByOne = false;
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
        } else if (message is StreamOfBestPathNumWithLinkRequest) {
          _latestStreamOfBestPathNumWithLinkRequest = message;
          // ignore: literal_only_boolean_expressions
          while (true) {
            if (_computingStreamOfBestPathNumWithLink) {
              await Future<void>.delayed(const Duration(milliseconds: 5));
              continue;
            }
            if (_latestStreamOfBestPathNumWithLinkRequest.movesAtRequest != message.movesAtRequest) {
              logger.d(
                '''
              The StreamOfBestPathNumWithLinkRequest (moves: ${message.movesAtRequest}) has dropped.
              It is because a new StreamOfBestPathNumWithLinkRequest (moves: ${_latestStreamOfBestPathNumWithLinkRequest.movesAtRequest}) has been received after that.
              ''',
              );
              break;
            }
            _computingStreamOfBestPathNumWithLink = true;
            await compute(
              _computeStreamOfBestPathNumWithLink,
              _ComputeStreamOfBestPathNumWithLinkParams(
                dllPath,
                _latestStreamOfBestPathNumWithLinkRequest,
                parentSendPort,
              ),
            );
            _computingStreamOfBestPathNumWithLink = false;
            break;
          }
        } else if (message is BookLoadRequest) {
          if (_computingBookLoading) return;
          _computingBookLoading = true;
          logger.i('will load book file. path: ${message.file}');
          await compute(_computeBookLoad, _ComputeBookLoadParams(dllPath, message, parentSendPort));
          _computingBookLoading = false;
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
class _ComputeStreamOfBestPathNumWithLinkParams {
  const _ComputeStreamOfBestPathNumWithLinkParams(this.dllPath, this.request, this.listener);
  final String dllPath;
  final StreamOfBestPathNumWithLinkRequest request;
  final SendPort listener;
}

// NOTE: top level function for `compute`.
@doNotStore
Future<void> _computeStreamOfBestPathNumWithLink(final _ComputeStreamOfBestPathNumWithLinkParams params) async {
  final edax = LibEdax(params.dllPath);
  await executeStreamOfBestPathNumWithLink(edax, params.request).listen(params.listener.send).asFuture<void>();
}
