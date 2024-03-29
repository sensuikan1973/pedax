import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

// See: https://github.com/authpass/macos_secure_bookmarks/blob/master/lib/macos_secure_bookmarks.dart
@isTest
void mockSecureBookmark() {
  if (!Platform.isMacOS) return;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('codeux.design/macos_secure_bookmarks'),
    (final methodCall) async {
      if (methodCall.method == 'startAccessingSecurityScopedResource') return false;
      if (methodCall.method == 'stopAccessingSecurityScopedResource') return false;
      if (methodCall.method == 'bookmarkData') return '';
      return null;
    },
  );
}
