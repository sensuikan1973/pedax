import 'package:meta/meta.dart';
import 'package:pedax/engine/options/native/book_file_option.dart';
import 'package:pedax/engine/options/native/eval_file_option.dart';
import 'package:pedax/engine/options/pedax/bestpath_count_availability_option.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _evalFileOption = EvalFileOption();
const _bookFileOption = BookFileOption();
const _bestpathCountAvailabilityOption = BestpathCountAvailabilityOption();

@isTest
// See: https://github.com/sensuikan1973/pedax/issues/522
// See: https://github.com/flutter/plugins/blob/main/packages/shared_preferences/shared_preferences/test/shared_preferences_test.dart
// See: https://pub.dev/packages/shared_preferences#testing
Future<void> fakeSharedPreferences({
  final String? evalFilePath,
  final String? bookFilePath,
  final bool enableBestpathCount = true,
  final String? bookmarkPrefKey,
}) async {
  final pref = {
    _evalFileOption.prefKey: evalFilePath ?? await _evalFileOption.appDefaultValue,
    _bookFileOption.prefKey: bookFilePath ?? await _bookFileOption.appDefaultValue,
    _bestpathCountAvailabilityOption.prefKey: enableBestpathCount,
    _bookFileOption.bookmarkPrefKey: bookmarkPrefKey ?? '',
  };
  SharedPreferencesStorePlatform.instance = FakeSharedPreferencesStore(pref);
}

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
}
