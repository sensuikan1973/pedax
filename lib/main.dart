import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // ignore: unused_import
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';
import 'engine/options/native/level_option.dart';
import 'engine/options/native/n_tasks_option.dart';
import 'engine/options/pedax/bestpath_count_availability_option.dart';
import 'engine/options/pedax/bestpath_count_opponent_lower_limit.dart';
import 'engine/options/pedax/bestpath_count_player_lower_limit.dart';
import 'engine/options/pedax/hint_step_by_step_option.dart';

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

  // See: https://github.com/getsentry/sentry-dart/tree/6.9.0/flutter#usage
  // See: https://docs.flutter.dev/testing/errors#errors-not-caught-by-flutter
  await runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) {
          // https://docs.sentry.io/platforms/flutter/#configure
          // https://pub.dev/documentation/sentry/latest/sentry_io/SentryOptions-class.html
          options
            ..dsn = const String.fromEnvironment('SENTRY_DSN') // ignore: do_not_use_environment
            ..tracesSampleRate = 1.0
            ..debug = kDebugMode
            ..beforeSend = sentryBeforeSend;
        },
        appRunner: () => runApp(const PedaxApp()),
      );
    },
    (exception, stackTrace) async => Sentry.captureException(exception, stackTrace: stackTrace),
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

// ignore: avoid_annotating_with_dynamic
FutureOr<SentryEvent?> sentryBeforeSend(SentryEvent event, {dynamic hint}) async {
  // https://docs.sentry.io/platforms/flutter/enriching-events/context/
  Sentry.configureScope((scope) async {
    await scope.setContexts(
      'edax engine options',
      {
        'LevelOption': await const LevelOption().val,
        'NTasksOption': await const NTasksOption().val,
        'BestpathCountAvailabilityOption': await const BestpathCountAvailabilityOption().val,
        'BestpathCountOpponentLowerLimitOption': await const BestpathCountOpponentLowerLimitOption().val,
        'BestpathCountPlayerLowerLimitOption': await const BestpathCountPlayerLowerLimitOption().val,
        'HintStepByStepOption': await const HintStepByStepOption().val,
      },
    );
  });
  final character = {
    'name': 'Mighty Fighter',
    'age': 19,
    'attack_type': 'melee',
  };
  Sentry.configureScope((scope) => scope.setContexts('character', character));
  return event;
}
