import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';
import 'window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(pedaxWindowMinSize);

  runApp(const PedaxApp());
}
