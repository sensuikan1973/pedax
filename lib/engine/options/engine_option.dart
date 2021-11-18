import 'package:meta/meta.dart';

@immutable
abstract class EngineOption<T> {
  String get prefKey;

  Future<T> get appDefaultValue;

  Future<T> get val;

  Future<T> update(final T val);
}
