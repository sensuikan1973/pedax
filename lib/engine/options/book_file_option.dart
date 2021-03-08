import 'dart:io';

import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';
import 'package:meta/meta.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import 'edax_option.dart';

@immutable
class BookFileOption extends EdaxOption<String> {
  const BookFileOption();

  @override
  String get nativeName => '-book-file';

  @override
  @visibleForTesting
  String get prefKey => 'bookFilePath';

  @override
  String get nativeDefaultValue => p.join('data', _defaultFileName); // relative path

  @override
  Future<String> get appDefaultValue async => p.join((await docDir).path, _defaultFileName);

  String get _defaultFileName => 'book.dat';

  // NOTE: When you don't need this value, you must call stopAccessingSecurityScopedResource.
  @override
  Future<String> get val async {
    final pref = await preferences;
    if (!Platform.isMacOS) return pref.getString(prefKey) ?? await appDefaultValue;

    final bookmark = pref.getString(bookmarkPrefKey);
    if (bookmark == null) return pref.getString(prefKey) ?? await appDefaultValue;
    final secureBookmarks = SecureBookmarks();
    final resolvedFile = await secureBookmarks.resolveBookmark(bookmark);
    final isOutOfSandbox = await secureBookmarks.startAccessingSecurityScopedResource(resolvedFile);
    if (isOutOfSandbox) Logger().i('access ${resolvedFile.path} which is out of sandbox.');
    return resolvedFile.path;
    // await secureBookmarks.stopAccessingSecurityScopedResource(resolvedFile);
  }

  @override
  Future<String> update(String val) async {
    final pref = await preferences;
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

  Future<void> stopAccessingSecurityScopedResource() async {
    if (!Platform.isMacOS) return;
    await SecureBookmarks().stopAccessingSecurityScopedResource(File(await val));
  }

  @visibleForTesting
  String get bookmarkPrefKey => 'BookmarkOfBookFilePath';
}
