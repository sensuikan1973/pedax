import 'package:meta/meta.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import 'edax_option.dart';

@immutable
class EvalFileOption extends EdaxOption<String> {
  const EvalFileOption();

  @override
  String get nativeName => '-eval-file';

  @override
  @visibleForTesting
  String get prefKey => 'evalFilePath';

  @override
  String get nativeDefaultValue => p.join('data', _defaultFileName); // relative path

  @override
  Future<String> get appDefaultValue async => p.join((await docDir).path, _defaultFileName);

  String get _defaultFileName => 'eval.dat';

  @override
  Future<String> get val async {
    final pref = await preferences;
    return pref.getString(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<String> update(String val) async {
    final pref = await preferences;
    if (val.isEmpty) {
      final newPath = await appDefaultValue;
      Logger().i('scpecified path is empty. So, pedax sets $newPath.');
      await pref.setString(prefKey, newPath);
      return appDefaultValue;
    } else {
      await pref.setString(prefKey, val);
      return val;
    }
  }
}
