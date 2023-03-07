// See: https://sensuikan1973.github.io/edax-reversi/structOptions.html
// See: https://github.com/lavox/edax-reversi/blob/libedax/src/edax.c

import '../engine_option.dart';

abstract class EngineNativeOption<T> implements EngineOption<T> {
  String get nativeName;
}
