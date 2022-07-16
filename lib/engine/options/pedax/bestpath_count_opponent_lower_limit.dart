import 'package:libedax4dart/libedax4dart.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'engine_pedax_option.dart';

@immutable
class BestpathCountOpponentLowerLimitOption implements EnginePedaxOption<int> {
  const BestpathCountOpponentLowerLimitOption();

  @override
  @visibleForTesting
  String get prefKey => 'BestpathCountOpponentLowerLimit';

  @override
  Future<int> get appDefaultValue async => BookCountBoardBestPathLowerLimit.best;

  @override
  Future<int> get val async {
    final pref = await _preferences;
    return pref.getInt(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<int> update(final int val) async {
    final pref = await _preferences;
    await pref.setInt(prefKey, val);
    return val;
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();
}
