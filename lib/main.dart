import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:logger/logger.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';
import 'window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureMinWindowSize();

  // If you feel debug log is noisy, you can change log level.
  // Logger.level = Level.info;

  runApp(const PedaxApp());
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
