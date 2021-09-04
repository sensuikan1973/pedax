import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edax_option.dart';

@immutable
class BestpathCountAvailabilityOption implements EdaxOption<bool> {
  const BestpathCountAvailabilityOption();

  @override
  String get nativeName => ''; // NOTE: nothing. this option is provided pedax.

  @override
  @visibleForTesting
  String get prefKey => 'BestpathCountAvailability';

  @override
  Future<bool> get appDefaultValue async => false;

  @override
  Future<bool> get val async {
    final pref = await _preferences;
    return pref.getBool(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<bool> update(final bool val) async {
    final pref = await _preferences;
    await pref.setBool(prefKey, val);
    return val;
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();
}
