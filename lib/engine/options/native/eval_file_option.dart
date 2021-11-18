import 'dart:io';

import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'engine_native_option.dart';

@immutable
class EvalFileOption implements EngineNativeOption<String> {
  const EvalFileOption();

  @override
  String get nativeName => '-eval-file';

  @override
  @visibleForTesting
  String get prefKey => 'evalFilePath';

  // REF: native default value is `./data/eval.dat`
  //      https://github.com/abulmo/edax-reversi/blob/01899aecce8bc780517149c80f178fb478a17a0b/src/options.c#L322
  @override
  Future<String> get appDefaultValue async => p.join((await _docDir).path, _defaultFileName);

  String get _defaultFileName => 'eval.dat';

  @override
  Future<String> get val async {
    final pref = await _preferences;
    return pref.getString(prefKey) ?? await appDefaultValue;
  }

  @override
  Future<String> update(final String val) async {
    final pref = await _preferences;
    if (val.isEmpty) {
      final newPath = await appDefaultValue;
      Logger().i('scpecified path is empty. So, pedax sets $newPath.');
      await pref.setString(prefKey, newPath);
      return newPath;
    } else {
      await pref.setString(prefKey, val);
      return val;
    }
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async => getApplicationDocumentsDirectory();
}
