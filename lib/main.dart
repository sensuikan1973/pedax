import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';

Future<void> main() async {
  if (kReleaseMode) {
    debugPrint = (message, {wrapWidth}) {};
  }
  runApp(const PedaxApp());
}
