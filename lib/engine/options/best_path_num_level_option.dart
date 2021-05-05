import 'package:meta/meta.dart';
import 'edax_option.dart';

@immutable
class BestPathNumLevelOption extends EdaxOption<int> {
  const BestPathNumLevelOption();

  @override
  String get nativeName => ''; // NOTE: nothing. this option is provided pedax.

  @override
  @visibleForTesting
  String get prefKey => 'BestPathNumLevel';

  @override
  Future<int> get appDefaultValue async => 10;

  @override
  Future<int> get val async {
    final pref = await preferences;
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
}
