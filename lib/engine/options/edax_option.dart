// See: https://sensuikan1973.github.io/edax-reversi/structOptions.html
// See: https://github.com/lavox/edax-reversi/blob/libedax/src/edax.c

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
abstract class EdaxOption<T> {
  const EdaxOption();

  String get nativeName;

  String get prefKey;

  Future<T> get appDefaultValue;

  Future<T> get val;

  Future<T> update(T val);

  @protected
  Future<SharedPreferences> get preferences async => SharedPreferences.getInstance();
}
