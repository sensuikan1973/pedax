import 'package:meta/meta.dart';
import 'package:pedax/engine/options/native/book_file_option.dart';
import 'package:pedax/engine/options/native/eval_file_option.dart';
import 'package:pedax/engine/options/pedax/bestpath_count_availability_option.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

const _evalFileOption = EvalFileOption();
final _bookFileOption = BookFileOption();
const _bestpathCountAvailabilityOption = BestpathCountAvailabilityOption();

// See: https://github.com/flutter/plugins/blob/debc272fb02a61832f92af717a6e0cb3ebce5c9a/packages/shared_preferences/shared_preferences/lib/shared_preferences.dart#L17
const _keyPrefix = 'flutter.';

// See: https://github.com/sensuikan1973/pedax/issues/522
// See: https://pub.dev/packages/shared_preferences#testing
@isTest
Future<void> fakeSharedPreferences({
  final String? evalFilePath,
  final String? bookFilePath,
  final bool? enableBestpathCount,
  final String? bookmarkPrefKey,
}) async {
  final pref = {
    '$_keyPrefix${_evalFileOption.prefKey}': evalFilePath ?? await _evalFileOption.appDefaultValue,
    '$_keyPrefix${_bookFileOption.prefKey}': bookFilePath ?? await _bookFileOption.appDefaultValue,
    '$_keyPrefix${_bestpathCountAvailabilityOption.prefKey}':
        enableBestpathCount ?? await _bestpathCountAvailabilityOption.appDefaultValue,
    '$_keyPrefix${_bookFileOption.bookmarkPrefKey}': bookmarkPrefKey ?? '',
  };
  SharedPreferencesStorePlatform.instance = FakeSharedPreferencesStore(pref);
}

// See: https://github.com/flutter/packages/blob/main/packages/shared_preferences/shared_preferences/test/shared_preferences_test.dart
@isTest
class FakeSharedPreferencesStore implements SharedPreferencesStorePlatform {
  FakeSharedPreferencesStore(Map<String, Object> data) : backend = InMemorySharedPreferencesStore.withData(data);

  final InMemorySharedPreferencesStore backend;

  @override
  bool get isMock => true;

  @override
  Future<bool> clear() => backend.clear();

  @override
  Future<Map<String, Object>> getAll() => backend.getAll();

  @override
  Future<bool> remove(String key) => backend.remove(key);

  @override
  Future<bool> setValue(String valueType, String key, Object value) => backend.setValue(valueType, key, value);

  @override
  Future<bool> clearWithPrefix(String prefix) => backend.clearWithPrefix(prefix);

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) => backend.clearWithParameters(parameters);

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) => backend.getAllWithPrefix(prefix);

  @override
  Future<Map<String, Object>> getAllWithParameters(GetAllParameters parameters) =>
      backend.getAllWithParameters(parameters);
}
