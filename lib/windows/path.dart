final _windowsAsciiPathPattern = RegExp(r'^([ -~]|[¥])+$'); // https://stackoverflow.com/a/14608823

bool isWindowsAsciiPath(final String path) => _windowsAsciiPathPattern.hasMatch(path);
