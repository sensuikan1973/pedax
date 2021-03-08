import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:logger/logger.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';
import 'window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(pedaxWindowMinSize);

  // If you feel debug log is noisy, you can change log level.
  // Logger.level = Level.info;

  runApp(const PedaxApp());
}
