import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edax_option.dart';

@immutable
class NTasksOption implements EdaxOption<int> {
  const NTasksOption();

  @override
  String get nativeName => '-n-tasks';

  @override
  @visibleForTesting
  String get prefKey => 'nTasks';

  @override
  int get nativeDefaultValue => 1;

  @override
  int get appDefaultValue => (Platform.numberOfProcessors / 4).floor();

  @override
  Future<int> get val async {
    final pref = await _pref;
    return pref.getInt(prefKey) ?? appDefaultValue;
  }

  @override
  Future<int> update(int val) async {
    final pref = await _pref;
    if (val < 1 || Platform.numberOfProcessors < val) {
      developer.log('$val is out of range acceptable for edax. So, pedax sets $appDefaultValue.');
      await pref.setInt(prefKey, appDefaultValue);
      return appDefaultValue;
    } else {
      await pref.setInt(prefKey, val);
      return val;
    }
  }

  Future<SharedPreferences> get _pref async => SharedPreferences.getInstance();
}
