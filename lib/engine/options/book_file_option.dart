import 'dart:io';

import 'package:logger/logger.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edax_option.dart';

@immutable
class BookFileOption implements EdaxOption<String> {
  const BookFileOption();

  @override
  String get nativeName => '-book-file';

  @override
  @visibleForTesting
  String get prefKey => 'bookFilePath';

  // REF: native default value is `./data/book.dat`
  //      https://github.com/abulmo/edax-reversi/blob/01899aecce8bc780517149c80f178fb478a17a0b/src/options.c#L323
  @override
  Future<String> get appDefaultValue async => p.join((await _docDir).path, _defaultFileName);

  String get _defaultFileName => 'book.dat';

  // NOTE: When you don't need this value, you must call stopAccessingSecurityScopedResource.
  @override
  Future<String> get val async {
    final pref = await _preferences;
    if (!Platform.isMacOS) return pref.getString(prefKey) ?? await appDefaultValue;

    final bookmark = pref.getString(bookmarkPrefKey);
    if (bookmark == null || bookmark.isEmpty) return pref.getString(prefKey) ?? await appDefaultValue;
    final secureBookmarks = SecureBookmarks();
    final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
    final isOutOfSandbox = await secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
    if (isOutOfSandbox) Logger().i('access ${resolvedFile.path} which is out of sandbox.');
    return resolvedFile.path;
    // await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
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
      if (Platform.isMacOS) {
        final bookmark = await SecureBookmarks().bookmark(File(val));
        await pref.setString(bookmarkPrefKey, bookmark);
      }
      return val;
    }
  }

  Future<SharedPreferences> get _preferences async => SharedPreferences.getInstance();

  Future<void> stopAccessingSecurityScopedResource() async {
    if (!Platform.isMacOS) return;
    await SecureBookmarks().stopAccessingSecurityScopedResource(File(await val));
  }

  @visibleForTesting
  String get bookmarkPrefKey => 'BookmarkOfBookFilePath';

  // e.g. Mac Sandbox App: ~/Library/Containers/com.example.pedax/Data/Documents
  Future<Directory> get _docDir async => getApplicationDocumentsDirectory();
}
