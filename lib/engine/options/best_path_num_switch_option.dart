import 'package:meta/meta.dart';
import 'edax_option.dart';

@immutable
class BestPathNumSwitchOption extends EdaxOption<bool> {
  const BestPathNumSwitchOption();

  @override
  String get nativeName => ''; // NOTE: nothing. this option is provided pedax.

  @override
  @visibleForTesting
  String get prefKey => 'BestPathNumSwitch';

  @override
  Future<bool> get appDefaultValue async => false;

  @override
  Future<bool> get val async {
    final pref = await preferences;
    return pref.getBool(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<bool> update(bool val) async {
    final pref = await preferences;
    await pref.setBool(prefKey, val);
    return val;
  }
}
