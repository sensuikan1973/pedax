import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'edax_option.dart';

@immutable
class EvalFileOption extends EdaxOption<String> {
  const EvalFileOption();

  @override
  String get nativeName => '-eval-file';

  @override
  @visibleForTesting
  String get prefKey => 'evalFilePath';

  @override
  String get nativeDefaultValue => 'data/$_defaultFileName'; // relative path

  @override
  Future<String> get appDefaultValue async => '${(await docDir).path}/$_defaultFileName';

  String get _defaultFileName => 'eval.dat';

  @override
  Future<String> get val async {
    final pref = await preferences;
    return pref.getString(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<String> update(String val) async {
    final pref = await preferences;
    if (val.isEmpty) {
      developer.log('scpecified path is empty. So, pedax sets $appDefaultValue.');
      await pref.setString(prefKey, await appDefaultValue);
      return appDefaultValue;
    } else {
      await pref.setString(prefKey, val);
      return val;
    }
  }
}
