import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedax/l10n/app_localizations.dart';

import 'pedax_shortcut.dart';

@immutable
class Rotate180Shortcut implements PedaxShortcut {
  const Rotate180Shortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelRotate180;

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestRotate180();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyM;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(final KeyEvent keyEvent) => HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey);
}
