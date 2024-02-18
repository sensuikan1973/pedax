import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class InitShortcut implements PedaxShortcut {
  const InitShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelInit;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyI;

  String get _keyLabel => logicalKey.keyLabel.toUpperCase();

  @override
  String get keys => Platform.isMacOS ? '⌃$_keyLabel or ⌘$_keyLabel' : 'Ctrl + $_keyLabel';

  @override
  bool fired(final KeyEvent keyEvent) =>
      (HardwareKeyboard.instance.isControlPressed && HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey)) ||
      (HardwareKeyboard.instance.isMetaPressed && HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey));

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async => args.boardNotifier.requestInit();
}
