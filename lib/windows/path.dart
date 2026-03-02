import 'dart:io';

import 'package:path/path.dart' as p;

final _windowsAsciiPathPattern = RegExp(r'^([ -~]|[¥])+$'); // https://stackoverflow.com/a/14608823

bool isWindowsAsciiPath(final String path) => _windowsAsciiPathPattern.hasMatch(path);

String? get windowsProgramDataPedaxPath {
  final programDataDir = Platform.environment['ProgramData'];
  if (programDataDir == null || programDataDir.isEmpty) return null;
  return p.join(programDataDir, 'pedax');
}
