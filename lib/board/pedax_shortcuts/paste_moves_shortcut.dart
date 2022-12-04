import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import 'pedax_shortcut.dart';

@immutable
class PasteMovesShorcut implements PedaxShorcut {
  const PasteMovesShorcut();

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelPasteMoves;

  @visibleForTesting
  static LogicalKeyboardKey get logicalKey => LogicalKeyboardKey.keyV;

  String get _keyLabel => logicalKey.keyLabel.toUpperCase();

  @override
  String get keys => Platform.isMacOS ? '^$_keyLabel or ⌘$_keyLabel' : 'Ctrl + $_keyLabel';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(logicalKey)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(logicalKey));

  @override
  Future<void> runEvent(final PedaxShortcutEventArguments args) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData == null || clipboardData.text == null) return;
    args.boardNotifier
      ..requestInit()
      ..requestPlay(clipboardData.text!);
  }
}
