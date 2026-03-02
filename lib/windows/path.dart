import 'dart:io';

import 'package:path/path.dart' as p;

final _windowsAsciiPathPattern = RegExp(r'^([ -~]|[¥])+$');

bool isWindowsAsciiPath(final String path) => _windowsAsciiPathPattern.hasMatch(path);

String? get windowsProgramDataPedaxPath {
  final programDataDir = Platform.environment['ProgramData'];
  if (programDataDir == null || programDataDir.isEmpty) return null;
  return p.join(programDataDir, 'pedax');
}
