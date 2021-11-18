import 'dart:io';
import 'dart:math';

import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine_native_option.dart';

@immutable
class NTasksOption implements EngineNativeOption<int> {
  const NTasksOption();

  @override
  String get nativeName => '-n-tasks';

  @override
  @visibleForTesting
  String get prefKey => 'nTasks';

  // REF: native default value is 1.
  //      https://github.com/abulmo/edax-reversi/blob/01899aecce8bc780517149c80f178fb478a17a0b/src/options.c#L27
  @override
  Future<int> get appDefaultValue async => max(Platform.numberOfProcessors / 4, 1).floor();

  @override
  Future<int> get val async {
    final pref = await _preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<int> update(final int val) async {
    final pref = await _preferences;
    if (val < 1 || Platform.numberOfProcessors < val) {
      final newN = await appDefaultValue;
      Logger().i('$val is out of range acceptable for edax. So, pedax sets $newN.');
      await pref.setInt(prefKey, newN);
      return appDefaultValue;
    } else {
      await pref.setInt(prefKey, val);
      return val;
    }
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();
}
