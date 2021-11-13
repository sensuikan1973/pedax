import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // ignore: depend_on_referenced_packages

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class PasteMovesShorcut implements PedaxShorcut {
  const PasteMovesShorcut(this.boardNotifier);

  final BoardNotifier boardNotifier;

  @override
  String label(final AppLocalizations localizations) => localizations.shortcutLabelPasteMoves;

  @override
  String get keys => Platform.isMacOS ? '⌃V or ⌘V' : 'Ctrl + V';

  @override
  bool fired(final RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(LogicalKeyboardKey.keyV)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(LogicalKeyboardKey.keyV));

  @override
  Future<void> runEvent() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null || clipboardData.text == null) return;
    boardNotifier
      ..requestInit()
      ..requestPlay(clipboardData.text!);
  }
}
