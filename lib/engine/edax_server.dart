import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:libedax4dart/libedax4dart.dart';

import 'api/book_load.dart';
import 'api/hint_one_by_one.dart';
import 'api/init.dart';
import 'api/move.dart';
import 'api/set_option.dart';
import 'api/shutdown.dart';

// NOTE: top level function for `isolate.spawn`.
Future<void> startEdaxServer(StartEdaxServerParams params) async {
  final server = EdaxServer(dllPath: params.dllPath);
  await server.start(params.parentSendPort, params.initLibedaxParameters);
}

@immutable
class StartEdaxServerParams {
  const StartEdaxServerParams(this.parentSendPort, this.dllPath, this.initLibedaxParameters);

  final SendPort parentSendPort;
  final String dllPath;
  final List<String> initLibedaxParameters;
}

@immutable
class EdaxServer {
  EdaxServer({required this.dllPath});

  final String dllPath;
  final _receivePort = ReceivePort();

  SendPort get sendPort => _receivePort.sendPort;
  String get serverName => 'EdaxServer';

  // NOTE: I want to ensure EdaxServer `isolatable`. So, params depending on platform should be injectable.
  Future<void> start(SendPort parentSendPort, List<String> initLibedaxParameters) async {
    IsolateNameServer.registerPortWithName(sendPort, serverName);

    parentSendPort.send(_receivePort.sendPort); // NOTE: notify my port to parent
    debugPrint('[EdaxServer] sent my port to parentSendPort');

    final edax = LibEdax(dllPath)
      ..libedaxInitialize(initLibedaxParameters)
      ..edaxInit()
      ..edaxVersion();

    // ignore: avoid_annotating_with_dynamic
    _receivePort.listen((dynamic message) {
      debugPrint('[EdaxServer] received ${message.runtimeType}');
      if (message is MoveRequest) {
        parentSendPort.send(executeMove(edax, message));
      } else if (message is HintOneByOneRequest) {
        executeHintOneByOne(edax, message).listen(parentSendPort.send);
      } else if (message is InitRequest) {
        parentSendPort.send(executeInit(edax, message));
      } else if (message is BookLoadRequest) {
        parentSendPort.send(executeBookLoad(edax, message));
      } else if (message is SetOptionRequest) {
        parentSendPort.send(executeSetOption(edax, message));
      } else if (message is ShutdownRequest) {
        parentSendPort.send(executeShutdown(edax, message));
        _receivePort.close();
        debugPrint('[EdaxServer] shutdowned');
      } else {
        throw Exception('[EdaxServer] request ${message.runtimeType} is not supported');
      }
    }); // TODO: error handling
  }
}
