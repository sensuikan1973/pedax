import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'pedax_shortcut.dart';

@immutable
class PasteMovesShorcut extends PedaxShorcut {
  const PasteMovesShorcut(BoardNotifier boardNotifier) : super(boardNotifier);

  @override
  String label(BuildContext context) => AppLocalizations.of(context)!.shortcutLabelPasteMoves;

  @override
  String get keys => Platform.isMacOS ? '⌃V or ⌘V' : 'Ctrl + V';

  @override
  bool fired(RawKeyEvent keyEvent) =>
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
