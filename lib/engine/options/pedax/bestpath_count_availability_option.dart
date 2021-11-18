import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'engine_pedax_option.dart';

@immutable
class BestpathCountAvailabilityOption implements EnginePedaxOption<bool> {
  const BestpathCountAvailabilityOption();

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
