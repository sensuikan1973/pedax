import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class RedoAllShortcut implements PedaxShortcut {
  const RedoAllShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelRedoAll;

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestRedoAll();

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyF;

  @override
  String get keys => logicalKey.keyLabel.toUpperCase();

  @override
  bool fired(final KeyEvent keyEvent) => HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey);
}
