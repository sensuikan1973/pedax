import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // ignore: unused_import
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';

@visibleForTesting
const pedaxWindowMinSize = Size(550, 680);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureMinWindowSize();

  // If you feel debug log is noisy, you can change log level.
  // Logger.level = Level.info;

  // https://docs.sentry.io/platforms/flutter/usage/#tips-for-catching-errors
  FlutterError.onError = (errorDetails) async {
    Logger().d(errorDetails.exception);
    await Sentry.captureException(errorDetails.exception, stackTrace: errorDetails.stack);
  };

  // https://docs.sentry.io/platforms/flutter/#configure
  const sentryDsn = String.fromEnvironment('SENTRY_DSN'); // ignore: do_not_use_environment
  Logger().d(sentryDsn);

  // See: https://github.com/getsentry/sentry-dart/tree/6.7.0/flutter#usage
  // See: https://docs.flutter.dev/testing/errors#errors-not-caught-by-flutter
  await runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) {
          // https://pub.dev/documentation/sentry/latest/sentry_io/SentryOptions-class.html
          options
            ..dsn = sentryDsn
            ..tracesSampleRate = 1.0;
          // ..attachThreads= true;
        },
        appRunner: () => runApp(const PedaxApp()),
      );
    },
    (exception, stackTrace) async {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    },
  );
}

// See: https://github.com/flutter/flutter/issues/30736
Future<void> _ensureMinWindowSize() async {
  setWindowMinSize(pedaxWindowMinSize);

  final windowInfo = await getWindowInfo();
  if (windowInfo.frame.width >= pedaxWindowMinSize.width && windowInfo.frame.height >= pedaxWindowMinSize.height) {
    return;
  }

  setWindowFrame(
    Rect.fromCenter(
      center: windowInfo.frame.center,
      width: pedaxWindowMinSize.width,
      height: pedaxWindowMinSize.height,
    ),
  );
}
