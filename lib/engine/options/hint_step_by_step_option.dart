import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edax_option.dart';

@immutable
class HintStepByStepOption implements EdaxOption<bool> {
  const HintStepByStepOption();

  @override
  String get nativeName => ''; // NOTE: nothing. this option is provided pedax.

  @override
  @visibleForTesting
  String get prefKey => 'hintStepByStep';

  @override
  Future<bool> get appDefaultValue async => true;

  @override
  Future<bool> get val async {
    final pref = await _preferences;
    return pref.getBool(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<bool> update(bool val) async {
    final pref = await _preferences;
    await pref.setBool(prefKey, val);
    return val;
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();
}
