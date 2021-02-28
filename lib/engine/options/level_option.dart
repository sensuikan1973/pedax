import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

import 'edax_option.dart';

@immutable
class LevelOption extends EdaxOption<int> {
  const LevelOption();

  @override
  String get nativeName => '-level';

  @override
  @visibleForTesting
  String get prefKey => 'level';

  @override
  int get nativeDefaultValue => 21;

  @override
  Future<int> get appDefaultValue async => 10;

  @override
  Future<int> get val async {
    final pref = await preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<int> update(int val) async {
    final pref = await preferences;
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
}
