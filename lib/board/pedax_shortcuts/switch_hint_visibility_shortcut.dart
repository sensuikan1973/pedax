import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedax/l10n/app_localizations.dart';

import 'pedax_shortcut.dart';

@immutable
class SwitchHintVisibilityShortcut implements PedaxShortcut {
  const SwitchHintVisibilityShortcut();

  @override
  String label(AppLocalizations localizations) => localizations.shortcutLabelSwitchHintVisibility;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyH;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(KeyEvent keyEvent) => HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey);

  @override
  Future<void> runEvent(PedaxShortcutEventArguments args) async => args.boardNotifier.switchHintVisibility();
}
