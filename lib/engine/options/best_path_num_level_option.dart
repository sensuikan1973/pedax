import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edax_option.dart';

@immutable
class BestPathNumLevelOption implements EdaxOption<int> {
  const BestPathNumLevelOption();

  @override
  String get nativeName => ''; // NOTE: nothing. this option is provided pedax.

  @override
  @visibleForTesting
  String get prefKey => 'BestPathNumLevel';

  @override
  Future<int> get appDefaultValue async => 8;

  @override
  Future<int> get val async {
    final pref = await _preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  // ignore: prefer_expression_function_bodies
  Future<int> update(int val) async {
    return appDefaultValue; // TODO: editable
    // final pref = await preferences;
    // await pref.setInt(prefKey, val);
    // return val;
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();
}
