import 'package:meta/meta.dart';
import 'package:pedax/engine/options/bestpath_count_availability_option.dart';
import 'package:pedax/engine/options/book_file_option.dart';
import 'package:pedax/engine/options/eval_file_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _evalFileOption = EvalFileOption();
const _bookFileOption = BookFileOption();
const _bestpathCountAvailabilityOption = BestpathCountAvailabilityOption();

@isTest
// See: https://pub.dev/packages/shared_preferences#testing
Future<void> mockSharedPreferences({
  final String? evalFilePath,
  final String? bookFilePath,
  final bool enableBestpathCount = true,
}) async {
  final pref = {
    _evalFileOption.prefKey: evalFilePath ?? await _evalFileOption.appDefaultValue,
    _bookFileOption.prefKey: bookFilePath ?? await _bookFileOption.appDefaultValue,
    _bestpathCountAvailabilityOption.prefKey: enableBestpathCount,
  };
  SharedPreferences.setMockInitialValues(pref);
}
