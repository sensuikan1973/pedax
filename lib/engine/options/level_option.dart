import 'package:flutter/foundation.dart';

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
  Future<int> get appDefaultValue async => nativeDefaultValue;

  @override
  Future<int> get val async {
    final pref = await preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<int> update(int val) async {
    final pref = await preferences;
    if (val < 0) {
      debugPrint('$val is invalid. So, pedax sets $appDefaultValue.');
      await pref.setInt(prefKey, await appDefaultValue);
      return appDefaultValue;
    } else {
      await pref.setInt(prefKey, val);
      return val;
    }
  }
}
