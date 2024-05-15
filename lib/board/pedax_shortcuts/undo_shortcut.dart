import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedax/l10n/app_localizations.dart';

import 'pedax_shortcut.dart';

@immutable
class UndoShortcut implements PedaxShortcut {
  const UndoShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelUndo;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyU => LogicalKeyboardKey.keyU;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowLeft => LogicalKeyboardKey.arrowLeft;

  @override
  String get keys => '${logicalKeyU.keyLabel.toUpperCase()} or ←';

  @override
  bool fired(final KeyEvent keyEvent) =>
      HardwareKeyboard.instance.isLogicalKeyPressed(logicalKeyU) ||
      HardwareKeyboard.instance.isLogicalKeyPressed(logicalKeyArrowLeft);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestUndo();
}
