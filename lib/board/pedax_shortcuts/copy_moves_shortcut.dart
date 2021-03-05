import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import '../../models/board_notifier.dart';

import 'pedax_shortcut.dart';

@immutable
class CopyMovesShorcut extends PedaxShorcut {
  const CopyMovesShorcut(BoardNotifier boardNotifier) : super(boardNotifier);

  @override
  String label(BuildContext context) => '';

  @override
  bool fired(RawKeyEvent keyEvent) =>
      (keyEvent.isControlPressed && keyEvent.isKeyPressed(LogicalKeyboardKey.keyC)) ||
      (keyEvent.data.isModifierPressed(ModifierKey.metaModifier) && keyEvent.isKeyPressed(LogicalKeyboardKey.keyC));

  @override
  Future<void> runEvent() async => Clipboard.setData(ClipboardData(text: boardNotifier.value.currentMoves));
}
