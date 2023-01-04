import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';

@visibleForTesting
const pedaxWindowMinSize = Size(550, 680);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(pedaxWindowMinSize); // https://github.com/flutter/flutter/issues/30736

  // https://github.com/sensuikan1973/pedax/issues/1159
  await windowManager.ensureInitialized(); // https://github.com/leanflutter/window_manager/tree/v0.2.9#usage
  await _setWindowFrame();

  // If you feel debug log is noisy, you can change log level.
  // Logger.level = Level.info;

  // https://docs.sentry.io/platforms/flutter/usage/#tips-for-catching-errors
  // https://docs.flutter.dev/testing/errors#errors-caught-by-flutter
  FlutterError.onError = (errorDetails) async {
    Logger().d(errorDetails.exception);
    await Sentry.captureException(errorDetails.exception, stackTrace: errorDetails.stack);
  };

  // https://github.com/getsentry/sentry-dart/tree/6.17.0/flutter#usage
  // https://docs.flutter.dev/testing/errors#errors-not-caught-by-flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };
  await SentryFlutter.init(
    (options) {
      // https://docs.sentry.io/platforms/flutter/#configure
      // https://pub.dev/documentation/sentry/latest/sentry_io/SentryOptions-class.html
      options
        ..dsn = const String.fromEnvironment('SENTRY_DSN') // ignore: do_not_use_environment
        ..tracesSampleRate = 1.0
        ..debug = kDebugMode;
    },
    appRunner: () => runApp(const PedaxApp()),
  );
}

Future<void> _setWindowFrame() async {
  final windowInfo = await getWindowInfo();
  setWindowFrame(
    Rect.fromLTWH(
      await PedaxApp.savedWindowFrameLeft ?? windowInfo.frame.left,
      await PedaxApp.savedWindowFrameTop ?? windowInfo.frame.top,
      await PedaxApp.savedWindowFrameWidth ?? pedaxWindowMinSize.width,
      await PedaxApp.savedWindowFrameHeight ?? pedaxWindowMinSize.height,
    ),
  );
}
