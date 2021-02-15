import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edax_option.dart';

@immutable
class BookFileOption extends EdaxOption<String> {
  const BookFileOption();

  @override
  String get nativeName => '-book-file';

  @override
  @visibleForTesting
  String get prefKey => 'bookFilePath';

  @override
  String get nativeDefaultValue => 'data/$_defaultFileName'; // relative path

  @override
  Future<String> get appDefaultValue async => '${(await docDir).path}/$_defaultFileName';

  String get _defaultFileName => 'book.dat';

  @override
  Future<String> get val async {
    final pref = await _pref;
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

  Future<SharedPreferences> get _pref async => SharedPreferences.getInstance();
}
