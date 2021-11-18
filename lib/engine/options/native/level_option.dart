import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine_native_option.dart';

@immutable
class LevelOption implements EngineNativeOption<int> {
  const LevelOption();

  @override
  String get nativeName => '-level';

  @override
  @visibleForTesting
  String get prefKey => 'level';

  // REF: native default value is 21.
  //      https://github.com/abulmo/edax-reversi/blob/01899aecce8bc780517149c80f178fb478a17a0b/src/options.c#L38
  @override
  Future<int> get appDefaultValue async => 10;

  @override
  Future<int> get val async {
    final pref = await _preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<int> update(final int val) async {
    final pref = await _preferences;
    if (val < 0) {
      final newLevel = await appDefaultValue;
      Logger().i('$val is invalid. So, pedax sets $newLevel.');
      await pref.setInt(prefKey, newLevel);
      return appDefaultValue;
    } else {
      await pref.setInt(prefKey, val);
      return val;
    }
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();
}
