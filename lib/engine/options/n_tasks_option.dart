import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'edax_option.dart';

@immutable
class NTasksOption extends EdaxOption<int> {
  const NTasksOption();

  @override
  String get nativeName => '-n-tasks';

  @override
  @visibleForTesting
  String get prefKey => 'nTasks';

  @override
  int get nativeDefaultValue => 1;

  @override
  Future<int> get appDefaultValue async => (Platform.numberOfProcessors / 4).floor();

  @override
  Future<int> get val async {
    final pref = await preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<int> update(int val) async {
    final pref = await preferences;
    if (val < 1 || Platform.numberOfProcessors < val) {
      developer.log('$val is out of range acceptable for edax. So, pedax sets $appDefaultValue.');
      await pref.setInt(prefKey, await appDefaultValue);
      return appDefaultValue;
    } else {
      await pref.setInt(prefKey, val);
      return val;
    }
  }
}
