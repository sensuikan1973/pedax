import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class RedoShortcut implements PedaxShortcut {
  const RedoShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelRedo;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyR => LogicalKeyboardKey.keyR;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKeyArrowRight => LogicalKeyboardKey.arrowRight;

  @override
  String get keys => '${logicalKeyR.keyLabel.toUpperCase()} or →';

  @override
  bool fired(final KeyEvent keyEvent) =>
      HardwareKeyboard.instance.isLogicalKeyPressed(logicalKeyR) ||
      HardwareKeyboard.instance.isLogicalKeyPressed(logicalKeyArrowRight);

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestRedo();
}
