// See: https://sensuikan1973.github.io/edax-reversi/structOptions.html
// See: https://github.com/lavox/edax-reversi/blob/libedax/src/edax.c

import 'package:meta/meta.dart';

import '../engine_option.dart';

@immutable
abstract class EngineNativeOption<T> implements EngineOption<T> {
  String get nativeName;
}
