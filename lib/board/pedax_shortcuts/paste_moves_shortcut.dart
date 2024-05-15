import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pedax/l10n/app_localizations.dart';

import 'pedax_shortcut.dart';

@immutable
class PasteMovesShortcut implements PedaxShortcut {
  const PasteMovesShortcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelPasteMoves;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyV;

  String get _keyLabel => logicalKey.keyLabel.toUpperCase();

  @override
  String get keys => Platform.isMacOS ? '^$_keyLabel or ⌘$_keyLabel' : 'Ctrl + $_keyLabel';

  @override
  bool fired(final KeyEvent keyEvent) =>
      (HardwareKeyboard.instance.isControlPressed && HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey)) ||
      (HardwareKeyboard.instance.isMetaPressed && HardwareKeyboard.instance.isLogicalKeyPressed(logicalKey));

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData == null || clipboardData.text == null) return;
    args.boardNotifier
      ..requestInit()
      ..requestPlay(clipboardData.text!);
  }
}
