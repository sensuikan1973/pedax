import 'package:meta/meta.dart';
import 'edax_option.dart';

@immutable
class HintStepByStepOption extends EdaxOption<bool> {
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
