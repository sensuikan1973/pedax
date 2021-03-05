import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../../models/board_notifier.dart';
import 'copy_moves_shortcut.dart';
import 'paste_moves_shortcut.dart';
import 'redo_all_shortcut.dart';
import 'redo_shortcut.dart';
import 'switch_hint_visibility.dart';
import 'undo_all_shortcut.dart';
import 'undo_shortcut.dart';

@immutable
abstract class PedaxShorcut {
  const PedaxShorcut(this.boardNotifier);
  final BoardNotifier boardNotifier;

  String label(BuildContext context);
  bool fired(RawKeyEvent keyEvent);
  Future<void> runEvent();
}

List<PedaxShorcut> shortcutList(BoardNotifier boardNotifier) => [
      CopyMovesShorcut(boardNotifier),
      PasteMovesShorcut(boardNotifier),
      RedoAllShorcut(boardNotifier),
      RedoShorcut(boardNotifier),
      SwitchHintVisibilityShorcut(boardNotifier),
      UndoAllShorcut(boardNotifier),
      UndoShorcut(boardNotifier),
    ];
