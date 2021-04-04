// See: https://sensuikan1973.github.io/edax-reversi/structOptions.html
// See: https://github.com/lavox/edax-reversi/blob/libedax/src/edax.c
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
abstract class EdaxOption<T> {
  const EdaxOption();

  String get nativeName;

  String get prefKey;

  Future<T> get appDefaultValue;

  Future<T> get val;

  Future<T> update(T val);

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  @protected
  Future<Directory> get docDir async => getApplicationDocumentsDirectory();

  @protected
  Future<SharedPreferences> get preferences async => SharedPreferences.getInstance();
}
